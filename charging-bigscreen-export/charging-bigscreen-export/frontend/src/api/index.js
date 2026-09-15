import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || '/api',
  timeout: 20000
})

/**
 * 大屏首屏聚合接口：一次请求获取全部面板数据，减少并发请求数
 */
export async function fetchScreenBundle() {
  const { data } = await http.get('/screen/bundle')
  if (data.code !== 0) throw new Error(data.msg || '接口返回异常')
  return { payload: data.data, updatedAt: data.updated_at }
}

export async function fetchHealth() {
  const { data } = await http.get('/health')
  return data.data
}
