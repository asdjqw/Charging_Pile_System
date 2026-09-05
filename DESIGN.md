---
version: alpha
name: "充电桩综合管理系统"
description: "面向充电运营人员与车主的电网调度式产品界面，强调实时状态、异常优先和高密度数据可读性。"
colors:
  ink: "#15201E"
  muted: "#64716E"
  canvas: "#F3F6F5"
  surface: "#FFFFFF"
  rail: "#20302D"
  primary: "#0D7565"
  info: "#2563A8"
  success: "#188568"
  warning: "#B66A11"
  danger: "#C34444"
  border: "#D8E0DE"
typography:
  sans:
    fontFamily: "Noto Sans CJK SC, Microsoft YaHei, system-ui, sans-serif"
  data:
    fontFamily: "Arial Narrow, Roboto Condensed, Noto Sans CJK SC, sans-serif"
rounded:
  DEFAULT: "0.375rem"
  sm: "0.25rem"
  md: "0.375rem"
  lg: "0.5rem"
spacing:
  control: "0.75rem"
  panel: "1rem"
  section: "1.125rem"
  page-max: "112.5rem"
components:
  button:
    minHeight: "2.25rem"
  panel:
    radius: "0.375rem"
  table:
    rowHeight: "2.625rem"
  statusBadge:
    radius: "0.25rem"
---

# 充电桩综合管理系统 Design System

## Overview

### Creative North Star

界面参考城市电力调度台和公共交通控制室：信息紧凑、状态明确、异常先于装饰。标志性元素是贯穿 Web 大屏的“运行信号带”，它把在线率、异常数和核心运营数据组织成可快速扫读的层级。

### Product context and register

- **Audience and primary job:** 运营人员监控营收、设备健康、订单和站点；车主完成找桩、预约、充电与结算。
- **Target market(s) and evidence:** 当前课程数据和业务说明面向中国大陆充电运营场景，站点数据以北京为主。
- **Locale(s) and language policy:** 产品文案使用简体中文，协议字段和内部状态转换为面向用户的中文标签。
- **Usage scene:** Web 大屏与管理端以桌面高频扫读为主，用户端以紧凑窗口模拟移动任务流。
- **Register:** 产品型界面。效率、可恢复性和状态识别优先于品牌展示。
- **Memorable signature:** 运行信号带与数字调度风格。
- **Restraint:** 表格、表单和危险操作保持熟悉、安静，不使用装饰性大图或营销式构图。
- **Anti-references:** 避免通篇天蓝、通篇深蓝、过度圆角卡片、渐变光斑和巨型营销标题。
- **Token ownership/runtime mapping:** 本文件记录规范，Web 运行时令牌由 `web/styles.css` 的 `:root` 变量实现；Qt 令牌后续映射到 `common/StyleHelper.h`。

## Colors

`canvas` 与 `surface` 提供低对比工作底色，`rail` 只用于顶部运行栏。`primary` 表示主要操作和正常运行，`info` 表示充电中或信息状态，`warning` 表示预约与需关注状态，`danger` 只用于故障、离线和危险操作。状态不能只依赖颜色，必须同时显示文字或数字。

## Typography

中文界面使用 `sans` 字体栈。KPI、金额、时间和设备数量使用 `data` 字体栈并启用等宽数字。页内标题保持紧凑，只有产品名称使用一级标题；表格和控件不使用展示型大字。

## Layout

Web 大屏最大宽度为 1800px，桌面端采用 12 列思维组织指标、图表和表格。关键运行信号占据首屏，规模指标使用连续信息带而不是独立浮动卡片。1200px 以下表格改为单列，760px 以下指标变为两列，表格允许容器内横向滚动且页面本身不得横向溢出。

Qt 用户端按手机窗口模拟：登录窗 `520×920`，主窗口默认 `540×960`。

## Elevation & Depth

层级主要依靠背景色、边框和留白。静态面板不使用明显阴影；仅顶部栏与内容区形成色调分层。粘性表头使用实色背景保证滚动可读性。

## Shapes

面板统一 6px 圆角，控件 4px，徽标 4px。图标按钮可以是正方形，不使用胶囊按钮；状态圆点是唯一常规圆形元素。

## Components

### Foundational visual states

所有交互元素必须具有 hover、focus-visible、disabled 和 busy 状态。加载状态保持原有几何尺寸；服务错误显示可恢复提示，空结果说明当前筛选没有数据。

### Buttons and actions

主要按钮使用 `primary`，次要按钮使用白色描边。刷新按钮在请求中保持宽度并显示“刷新中”。翻页与清除使用熟悉符号并提供中文 `aria-label` 与 tooltip。

### Navigation and data display

指标按“运行风险、当期经营、规模资产”排序。表格使用固定表头、数值等宽、语义状态徽标；长站名允许两行并保持行高稳定。

### Forms and overlays

搜索采用显式提交，非空查询必须提供清除按钮；Enter 提交必须兼容中文输入法组合状态。错误后保留查询条件并允许重试。

### Iconography

没有项目级图标库时只使用通用字符符号，尺寸为 16px，并通过 `aria-hidden` 隐藏；所有不熟悉的图标必须保留文字标签或 tooltip。后续引入图标库时统一使用 Lucide。

### Motion

图表更新动画控制在 320ms 内，控件反馈控制在 160ms 内。动画只表达数据刷新和状态改变；系统偏好减少动画时全部关闭。

### Content and data visualization

文案使用直接的运营词汇。金额统一保留两位小数，数量使用千位分隔，时间显示本地时区。图表颜色与状态令牌一致，并启用 ECharts 无障碍描述。

## Do's and Don'ts

- **Do:** 让异常数、在线率和充电中设备比累计规模更容易被看到。
- **Do:** 在 Web 和 Qt 中复用同一套状态颜色和中文状态词。
- **Don't:** 把每个数字都做成同等权重的卡片。
- **Don't:** 用单一蓝色、阴影和大圆角代替信息层级。
