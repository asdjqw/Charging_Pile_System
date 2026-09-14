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

/**
 * 大屏首屏聚合接口：一次请求获取全部面板数据，减少并发请求数
 */
export async function fetchScreenBundle() {
  const data = await getJson('/screen/bundle')
  if (data.code !== 0) throw new Error(data.msg || '接口返回异常')
  return { payload: data.data, updatedAt: data.updated_at }
}

export async function fetchHealth() {
  const data = await getJson('/health')
  return data.data
}
