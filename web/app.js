const $ = (id) => document.getElementById(id);
const moneyFormatter = new Intl.NumberFormat("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const integerFormatter = new Intl.NumberFormat("zh-CN", { maximumFractionDigits: 0 });
const money = (value) => moneyFormatter.format(Number(value || 0));
const integer = (value) => integerFormatter.format(Number(value || 0));
const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (character) => ({
  "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;"
})[character]);

const statusNames = {
  idle: "空闲", charging: "充电中", reserved: "已预约", fault: "故障",
  offline: "离线", restarting: "重启中", finished: "已完成", ongoing: "进行中",
  open: "营业中", closed: "已关闭", maintenance: "维护中"
};
const statusTones = {
  idle: "success", open: "success", finished: "success",
  charging: "info", ongoing: "info",
  reserved: "warning", restarting: "warning", maintenance: "warning",
  fault: "danger", offline: "danger", closed: "neutral"
};

let currentDays = 7;
const stationPageSize = 20;
let stationPage = 1;
let stationTotal = 0;
let stationQuery = "";
let stationRequestId = 0;
let dashboardRequestId = 0;
const salesChart = echarts.init($("salesChart"));
const statusChart = echarts.init($("statusChart"));

async function getJson(path) {
  const response = await fetch(path, { cache: "no-store" });
  const body = await response.json();
  if (!response.ok || !body.ok) throw new Error(body.message || `HTTP ${response.status}`);
  return body.data;
}

function statusTag(status) {
  const label = statusNames[status] || status || "未知";
  const tone = statusTones[status] || "neutral";
  return `<span class="tag tag-${tone}">${escapeHtml(label)}</span>`;
}

function setHealth(state, message) {
  const health = $("health");
  health.textContent = message;
  health.dataset.state = state;
}

function announce(message) {
  $("announcement").textContent = "";
  window.setTimeout(() => { $("announcement").textContent = message; }, 10);
}

function drawSales(values) {
  const hasData = values.some((item) => Number(item.amount || 0) > 0);
  salesChart.setOption({
    animationDuration: 320,
    aria: { enabled: true, description: `近 ${currentDays} 日营收趋势图` },
    color: ["#0d7565"],
    grid: { left: 12, right: 20, top: 24, bottom: 10, containLabel: true },
    tooltip: { trigger: "axis", valueFormatter: (value) => `¥${money(value)}` },
    xAxis: {
      type: "category", boundaryGap: false, data: values.map((item) => item.date.slice(5)),
      axisLabel: { color: "#64716e", hideOverlap: true },
      axisTick: { show: false }, axisLine: { lineStyle: { color: "#d8e0de" } }
    },
    yAxis: {
      type: "value", axisLabel: { color: "#64716e", formatter: (value) => `¥${integer(value)}` },
      splitLine: { lineStyle: { color: "#e8edeb" } }
    },
    graphic: hasData ? [] : [{
      type: "text", left: "center", top: "middle",
      style: { text: "当前周期暂无营收", fill: "#75827f", font: "13px sans-serif" }
    }],
    series: [{
      name: "营收", type: "line", smooth: 0.28, symbol: "circle", symbolSize: 6,
      lineStyle: { width: 2.5 }, itemStyle: { borderWidth: 2, borderColor: "#fff" },
      areaStyle: { color: "rgba(13,117,101,.09)" },
      data: values.map((item) => Number(item.amount || 0))
    }]
  }, true);
}

function drawStatus(stats) {
  const values = [
    { name: "空闲", value: Number(stats.idlePiles || 0), itemStyle: { color: "#188568" } },
    { name: "充电中", value: Number(stats.chargingPiles || 0), itemStyle: { color: "#2563a8" } },
    { name: "已预约", value: Number(stats.reservedPiles || 0), itemStyle: { color: "#d79b43" } },
    { name: "故障", value: Number(stats.faultPiles || 0), itemStyle: { color: "#c34444" } },
    { name: "离线", value: Number(stats.offlinePiles || 0), itemStyle: { color: "#87938f" } },
    { name: "重启中", value: Number(stats.restartingPiles || 0), itemStyle: { color: "#8a6ca8" } }
  ];
  const onlineRate = Number(stats.onlineRate || 0).toFixed(1);
  statusChart.setOption({
    animationDuration: 320,
    aria: { enabled: true, description: `电桩运行状态分布，设备在线率 ${onlineRate}%` },
    title: {
      text: `${onlineRate}%`, subtext: "设备在线率", left: "center", top: "30%",
      textStyle: { color: "#15201e", fontSize: 26, fontWeight: 700 },
      subtextStyle: { color: "#64716e", fontSize: 11 }
    },
    tooltip: { trigger: "item", formatter: "{b}<br>{c} 台 ({d}%)" },
    legend: { bottom: 0, itemWidth: 9, itemHeight: 9, textStyle: { color: "#586662", fontSize: 11 } },
    series: [{
      name: "设备状态", type: "pie", radius: ["52%", "72%"], center: ["50%", "42%"],
      itemStyle: { borderColor: "#fff", borderWidth: 2 }, label: { show: false }, data: values
    }]
  }, true);
  $("pileTotal").textContent = `共 ${integer(stats.totalPiles)} 台`;
}

function renderOrders(orders) {
  $("ordersBody").innerHTML = orders.length ? orders.map((order) => `
    <tr><td class="numeric">${escapeHtml(order.orderNo)}</td><td>${escapeHtml(order.username || "--")}</td>
    <td class="cell-station" title="${escapeHtml(order.stationName || "--")}">${escapeHtml(order.stationName || "--")}</td>
    <td class="numeric">${money(order.energyKwh)} kWh</td><td class="numeric">¥${money(order.amount)}</td><td>${statusTag(order.status)}</td></tr>`).join("")
    : `<tr><td class="empty" colspan="6">当前还没有已完成订单</td></tr>`;
}

function renderStations(stations) {
  const rows = stations.map((station) => {
    const rate = Number(station.onlineRate || 0);
    const rateTone = rate >= 95 ? "good" : rate >= 80 ? "warning" : "danger";
    return `<tr><td class="cell-station" title="${escapeHtml(station.name)}">${escapeHtml(station.name)}</td>
      <td>${escapeHtml(station.regionCode || "--")}</td><td><span class="rate rate-${rateTone}">${rate.toFixed(1)}%</span></td>
      <td class="numeric">${integer(station.idlePiles)}/${integer(station.totalPiles)}</td><td>${statusTag(station.status)}</td></tr>`;
  }).join("");
  $("stationsBody").innerHTML = rows || `<tr><td class="empty" colspan="5">没有找到匹配站点，请调整搜索词</td></tr>`;
}

function setStationBusy(busy) {
  $("stationSearch").disabled = busy;
  $("stationPrev").disabled = busy || stationPage <= 1;
  $("stationNext").disabled = busy || stationPage >= Math.max(1, Math.ceil(stationTotal / stationPageSize));
  $("stationsBody").setAttribute("aria-busy", String(busy));
}

async function loadStations(page = stationPage, shouldAnnounce = false) {
  const requestId = ++stationRequestId;
  const requestedPage = Math.max(1, page);
  const offset = (requestedPage - 1) * stationPageSize;
  const query = encodeURIComponent(stationQuery);
  setStationBusy(true);
  try {
    const data = await getJson(`/api/stations?limit=${stationPageSize}&offset=${offset}&q=${query}`);
    if (requestId !== stationRequestId) return;
    stationTotal = Number(data.total || 0);
    const pageCount = Math.max(1, Math.ceil(stationTotal / stationPageSize));
    stationPage = Math.min(requestedPage, pageCount);
    renderStations(data.items || []);
    $("stationProgress").textContent = `第 ${stationPage} / ${pageCount} 页 · 共 ${integer(stationTotal)} 个站点`;
    if (shouldAnnounce) announce(`已显示第 ${stationPage} 页，共 ${stationTotal} 个站点`);
  } finally {
    if (requestId === stationRequestId) setStationBusy(false);
  }
}

async function runStationLoad(page, shouldAnnounce = true) {
  try {
    await loadStations(page, shouldAnnounce);
  } catch (error) {
    setHealth("error", "站点服务异常");
    $("stationsBody").innerHTML = `<tr><td class="empty" colspan="5">站点数据加载失败，请稍后重试</td></tr>`;
    announce(`站点数据加载失败：${error.message}`);
  }
}

function renderDashboard(dashboard) {
  const stats = dashboard.stats;
  $("todayAmount").textContent = money(stats.todayAmount);
  $("monthAmount").textContent = money(stats.monthAmount);
  $("totalAmount").textContent = money(stats.totalAmount);
  $("totalOrders").textContent = integer(stats.totalOrders);
  $("totalUsers").textContent = integer(stats.totalUsers);
  $("totalStations").textContent = integer(stats.totalStations);
  $("onlineRate").textContent = Number(stats.onlineRate || 0).toFixed(1);
  $("idlePiles").textContent = integer(stats.idlePiles);
  $("chargingPiles").textContent = integer(stats.chargingPiles);
  $("reservedPiles").textContent = integer(stats.reservedPiles);
  $("abnormalPiles").textContent = integer(Number(stats.faultPiles) + Number(stats.offlinePiles));
  drawSales(dashboard.dailySales || []);
  drawStatus(stats);
  renderOrders(dashboard.recentOrders || []);
}

async function refresh({ reloadStations = false, shouldAnnounce = false } = {}) {
  const requestId = ++dashboardRequestId;
  const refreshButton = $("refresh");
  refreshButton.disabled = true;
  refreshButton.setAttribute("aria-busy", "true");
  refreshButton.querySelector(".button-label").textContent = "刷新中";
  document.body.classList.add("is-loading");
  try {
    const dashboard = await getJson(`/api/dashboard?days=${currentDays}`);
    if (requestId !== dashboardRequestId) return;
    renderDashboard(dashboard);
    if (reloadStations) await loadStations(stationPage, false);
    const now = new Date();
    $("lastUpdated").textContent = `最后同步 ${now.toLocaleTimeString("zh-CN", { hour12: false })}`;
    setHealth("ok", "本地服务正常");
    if (shouldAnnounce) announce("运营数据已刷新");
  } catch (error) {
    if (requestId !== dashboardRequestId) return;
    setHealth("error", "本地服务异常");
    $("lastUpdated").textContent = "同步失败，可手动重试";
    if (shouldAnnounce) announce(`数据刷新失败：${error.message}`);
  } finally {
    if (requestId === dashboardRequestId) {
      refreshButton.disabled = false;
      refreshButton.setAttribute("aria-busy", "false");
      refreshButton.querySelector(".button-label").textContent = "刷新数据";
      document.body.classList.remove("is-loading");
    }
  }
}

function updateClock() {
  $("clock").textContent = new Date().toLocaleString("zh-CN", { hour12: false });
}

function updateClearButton() {
  $("stationClear").hidden = $("stationQuery").value.length === 0;
}

function submitStationSearch() {
  stationQuery = $("stationQuery").value.trim();
  runStationLoad(1, true);
}

$("salesDays").addEventListener("click", (event) => {
  const button = event.target.closest("button[data-days]");
  if (!button) return;
  currentDays = Number(button.dataset.days);
  $("salesTitle").textContent = `近 ${currentDays} 日营收趋势`;
  $("salesDays").querySelectorAll("button").forEach((item) => {
    item.setAttribute("aria-pressed", String(item === button));
  });
  refresh({ shouldAnnounce: true });
});
$("refresh").addEventListener("click", () => refresh({ reloadStations: true, shouldAnnounce: true }));
$("stationSearch").addEventListener("click", submitStationSearch);
$("stationQuery").addEventListener("input", updateClearButton);
$("stationQuery").addEventListener("keydown", (event) => {
  if (event.key === "Enter" && !event.isComposing) submitStationSearch();
});
$("stationClear").addEventListener("click", () => {
  $("stationQuery").value = "";
  stationQuery = "";
  updateClearButton();
  $("stationQuery").focus();
  runStationLoad(1, true);
});
$("stationPrev").addEventListener("click", () => runStationLoad(stationPage - 1));
$("stationNext").addEventListener("click", () => runStationLoad(stationPage + 1));
window.addEventListener("resize", () => { salesChart.resize(); statusChart.resize(); });
window.setInterval(updateClock, 1000);
window.setInterval(() => refresh(), 10000);
updateClock();
updateClearButton();
refresh({ reloadStations: true });
