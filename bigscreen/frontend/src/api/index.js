import axios from 'axios'

/**
 * 接口地址解析：
 *   1) 同源 /api（本项目由 Flask 或 nginx 托管时使用，也是默认方式）
 *   2) 若同源不是我们的服务（例如把大屏静态页放到别的系统里托管），自动回退到同主机 5000 端口的 Flask
 *   3) 也可以用 VITE_API_BASE 在构建时写死地址
 */
const envBase = import.meta.env.VITE_API_BASE
const candidateBases = []

if (envBase) {
  candidateBases.push(envBase.replace(/\/$/, ''))
} else {
  candidateBases.push('/api')
  if (typeof window !== 'undefined' && window.location.hostname) {
    const { protocol, hostname } = window.location
    const fallback = `${protocol}//${hostname}:5000/api`
    if (!candidateBases.includes(fallback)) candidateBases.push(fallback)
  }
}

let activeBase = candidateBases[0]

const http = axios.create({ timeout: 20000 })

async function getJson(path) {
  const ordered = [activeBase, ...candidateBases.filter((base) => base !== activeBase)]
  let lastError = null
  for (const base of ordered) {
    try {
      const { data } = await http.get(`${base}${path}`, { headers: { 'Cache-Control': 'no-cache' } })
      activeBase = base
      return data
    } catch (err) {
      lastError = err
    }
  }
  throw lastError || new Error('接口请求失败')
}

async function fetchPanel(path) {
  const data = await getJson(path)
  if (data.code !== 0) throw new Error(data.msg || '接口返回异常')
  return data.data
}

// 一张图表对应一个 Flask 接口；接口内部只读取同名的一张 MySQL ADS 表。
export const fetchOverview = () => fetchPanel('/overview')
export const fetchDailyTrend = () => fetchPanel('/charts/daily-trend')
export const fetchMonthlyTrend = () => fetchPanel('/charts/monthly-trend')
export const fetchHourLoad = () => fetchPanel('/charts/hour-load')
export const fetchWeekdayHourHeat = () => fetchPanel('/charts/weekday-hour-heat')
export const fetchStationTop = () => fetchPanel('/charts/station-top')
export const fetchFacilityCompare = () => fetchPanel('/charts/facility-compare')
export const fetchWeekendCompare = () => fetchPanel('/charts/weekend-compare')
export const fetchTimePeriodCompare = () => fetchPanel('/charts/time-period-compare')
export const fetchPlatformCompare = () => fetchPanel('/charts/platform-compare')
export const fetchDistrictCompare = () => fetchPanel('/charts/district-compare')
export const fetchDurationDist = () => fetchPanel('/charts/duration-dist')
export const fetchEnergyDist = () => fetchPanel('/charts/energy-dist')
export const fetchUserSegment = () => fetchPanel('/charts/user-segment')
export const fetchBatteryHealth = () => fetchPanel('/charts/battery-health')
export const fetchRevenueStruct = () => fetchPanel('/charts/revenue-struct')
export const fetchRealtimeSessions = () => fetchPanel('/charts/realtime-sessions')
export const fetchQuality = () => fetchPanel('/quality')
export const fetchPipeline = () => fetchPanel('/pipeline')

export async function fetchHealth() {
  const data = await getJson('/health')
  return data.data
}

/**
 * 机器学习预测接口（ml/ 子模块的只读蓝图，挂在同一个 Flask 上）：
 *   不传站点时返回最新批次里的全部站点，传站点时只返回该站点。
 */
export async function fetchForecast(stationId) {
  const path = stationId ? `/forecast/station/${encodeURIComponent(stationId)}` : '/forecast/latest'
  const data = await getJson(path)
  if (data.code !== 0) throw new Error(data.msg || '预测接口返回异常')
  return data.data
}
