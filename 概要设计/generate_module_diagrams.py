#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成概要设计说明书中的模块结构图与时序图。

风格对齐 Visio 分层架构图：界面层（浅蓝）→ 业务子模块（浅橙）
→ 支撑与接口（深橙/黄）→ 服务端（灰），蓝色箭头表示调用方向。

用法（在本文件夹内执行，不依赖工程其它目录）：
    python generate_module_diagrams.py
    python generate_module_diagrams.py --out figures
"""

from __future__ import annotations

import argparse
import os
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Sequence, Tuple

import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Rectangle


# —— 与样图一致的配色 ——
C_UI = "#D6EAF8"
C_BIZ = "#FCE4D6"
C_SUP = "#ED7D31"
C_MODEL = "#FFD966"
C_SERVER = "#D9D9D9"
C_LABEL = "#C45911"
C_ARROW = "#2E75B6"
C_TITLE = "#1F4E79"
C_TEXT = "#1F1F1F"
C_EDGE = "#7F7F7F"
C_LIFE = "#9DC3E6"
C_ACTOR = "#D6EAF8"


def _pick_font() -> str:
    candidates = [
        "Microsoft YaHei",
        "Microsoft YaHei UI",
        "SimHei",
        "Noto Sans CJK SC",
        "Noto Sans CJK JP",
        "Source Han Sans SC",
        "WenQuanYi Micro Hei",
        "PingFang SC",
        "STHeiti",
        "Arial Unicode MS",
    ]
    available = {f.name for f in font_manager.fontManager.ttflist}
    for name in candidates:
        if name in available:
            return name
    # 部分环境字体名带后缀
    for f in font_manager.fontManager.ttflist:
        lower = f.name.lower()
        if "yahei" in lower or "simhei" in lower or "cjk" in lower or "noto sans" in lower:
            return f.name
    return "DejaVu Sans"


FONT = _pick_font()
plt.rcParams["font.family"] = FONT
plt.rcParams["axes.unicode_minus"] = False
plt.rcParams["pdf.fonttype"] = 42


@dataclass
class Box:
    box_id: str
    title: str
    subtitle: str = ""
    color: str = C_BIZ
    x: float = 0.0
    y: float = 0.0
    w: float = 1.0
    h: float = 1.0
    title_size: float = 11.5
    sub_size: float = 8.6


@dataclass
class Arrow:
    src: str
    dst: str
    bidir: bool = False
    label: str = ""
    rad: float = 0.0


@dataclass
class Layer:
    name: str
    boxes: List[Box] = field(default_factory=list)


def _round_box(ax, box: Box, z: int = 3) -> None:
    patch = FancyBboxPatch(
        (box.x, box.y),
        box.w,
        box.h,
        boxstyle="round,pad=0.012,rounding_size=0.10",
        linewidth=1.15,
        edgecolor=C_EDGE,
        facecolor=box.color,
        mutation_aspect=0.6,
        zorder=z,
    )
    ax.add_patch(patch)
    cx = box.x + box.w / 2
    if box.subtitle:
        ax.text(
            cx,
            box.y + box.h * 0.66,
            box.title,
            ha="center",
            va="center",
            fontsize=box.title_size,
            fontweight="bold",
            color=C_TEXT,
            zorder=z + 1,
        )
        ax.text(
            cx,
            box.y + box.h * 0.32,
            box.subtitle,
            ha="center",
            va="center",
            fontsize=box.sub_size,
            color="#333333",
            linespacing=1.35,
            zorder=z + 1,
        )
    else:
        ax.text(
            cx,
            box.y + box.h / 2,
            box.title,
            ha="center",
            va="center",
            fontsize=box.title_size,
            fontweight="bold",
            color=C_TEXT,
            zorder=z + 1,
        )


def _anchor(box: Box, side: str) -> Tuple[float, float]:
    cx = box.x + box.w / 2
    cy = box.y + box.h / 2
    if side == "n":
        return cx, box.y + box.h
    if side == "s":
        return cx, box.y
    if side == "e":
        return box.x + box.w, cy
    if side == "w":
        return box.x, cy
    return cx, cy


def _choose_sides(a: Box, b: Box) -> Tuple[str, str]:
    a_top, a_bot = a.y + a.h, a.y
    b_top, b_bot = b.y + b.h, b.y
    y_overlap = not (a_bot > b_top - 0.02 or b_bot > a_top - 0.02)
    if not y_overlap:
        # 不同层之间一律上下连接，避免斜向误连到邻框。
        return ("n", "s") if (b.y + b.h / 2) > (a.y + a.h / 2) else ("s", "n")
    return ("e", "w") if (b.x + b.w / 2) > (a.x + a.w / 2) else ("w", "e")


def _draw_arrow(ax, a: Box, b: Box, spec: Arrow) -> None:
    s1, s2 = _choose_sides(a, b)
    x1, y1 = _anchor(a, s1)
    x2, y2 = _anchor(b, s2)
    style = "<|-|>" if spec.bidir else "-|>"
    conn = f"arc3,rad={spec.rad}" if spec.rad else "arc3,rad=0"
    patch = FancyArrowPatch(
        (x1, y1),
        (x2, y2),
        arrowstyle=style,
        mutation_scale=12,
        linewidth=1.35,
        color=C_ARROW,
        connectionstyle=conn,
        zorder=5,
        shrinkA=1.5,
        shrinkB=1.5,
    )
    ax.add_patch(patch)
    if spec.label:
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(
            mx + 0.08,
            my + 0.04,
            spec.label,
            ha="center",
            va="bottom",
            fontsize=8.5,
            color=C_ARROW,
            fontweight="bold",
            zorder=6,
        )


def draw_architecture(
    title: str,
    layers: Sequence[Layer],
    arrows: Sequence[Arrow],
    outfile: str,
    figsize: Tuple[float, float] = (13.4, 8.6),
    caption: str = "",
) -> None:
    all_boxes = [b for layer in layers for b in layer.boxes]
    # FancyBbox 的 pad 会超出给定矩形，按视觉外沿留白。
    max_top = max(b.y + b.h for b in all_boxes) + 0.16
    title_band = 0.85
    ylim_top = max_top + title_band
    data_w = 13.2
    fig_w = figsize[0]
    fig_h = max(figsize[1], fig_w * ylim_top / data_w + 0.55)

    fig, ax = plt.subplots(figsize=(fig_w, fig_h), dpi=160)
    fig.patch.set_facecolor("white")
    ax.set_xlim(0, data_w)
    ax.set_ylim(0, ylim_top)
    ax.set_aspect("equal")
    ax.axis("off")

    index: Dict[str, Box] = {}
    for layer in layers:
        if layer.name:
            ys = [b.y for b in layer.boxes]
            hs = [b.h for b in layer.boxes]
            mid = (min(ys) + max(y + h for y, h in zip(ys, hs))) / 2
            ax.text(
                0.22,
                mid,
                layer.name,
                ha="left",
                va="center",
                fontsize=11,
                fontweight="bold",
                color=C_LABEL,
                rotation=0,
            )
        for box in layer.boxes:
            _round_box(ax, box)
            index[box.box_id] = box

    for spec in arrows:
        _draw_arrow(ax, index[spec.src], index[spec.dst], spec)

    if caption:
        ax.text(6.6, 0.22, caption, ha="center", va="center",
                fontsize=8.5, color="#666666")

    # 标题最后画，放在所有模块框上方，避免被圆角框盖住。
    ax.text(
        6.6,
        max_top + 0.42,
        title,
        ha="center",
        va="center",
        fontsize=16,
        fontweight="bold",
        color=C_TITLE,
        zorder=20,
        clip_on=False,
    )

    fig.subplots_adjust(left=0.03, right=0.99, top=0.97, bottom=0.04)
    os.makedirs(os.path.dirname(outfile) or ".", exist_ok=True)
    fig.savefig(outfile, bbox_inches="tight", pad_inches=0.28, facecolor="white")
    plt.close(fig)


def draw_sequence(
    title: str,
    actors: Sequence[str],
    messages: Sequence[Tuple],
    outfile: str,
    note: str = "",
) -> None:
    """
    messages 元素：
        (from_idx, to_idx, text)
        (from_idx, to_idx, text, "reply")   虚线返回
        (from_idx, from_idx, text, "self")  自调用
    """
    n = len(actors)
    rows = len(messages)
    width = max(11.5, 2.35 * n + 1.4)
    height = max(5.8, 1.55 + 0.52 * rows + (0.45 if note else 0))
    fig, ax = plt.subplots(figsize=(width, height), dpi=160)
    fig.patch.set_facecolor("white")
    ax.set_xlim(0, width)
    ax.set_ylim(0, height)
    ax.axis("off")

    ax.text(width / 2, height - 0.32, title, ha="center", va="center",
            fontsize=14.5, fontweight="bold", color=C_TITLE)

    xs = [1.15 + i * (width - 1.6) / max(n - 1, 1) for i in range(n)]
    head_y = height - 0.95
    life_top = head_y - 0.42
    life_bot = 0.55 if note else 0.35

    for i, name in enumerate(actors):
        bw, bh = 1.85, 0.62
        box = FancyBboxPatch(
            (xs[i] - bw / 2, head_y - bh / 2),
            bw,
            bh,
            boxstyle="round,pad=0.01,rounding_size=0.08",
            linewidth=1.1,
            edgecolor=C_EDGE,
            facecolor=C_ACTOR,
            zorder=4,
        )
        ax.add_patch(box)
        ax.text(xs[i], head_y, name, ha="center", va="center",
                fontsize=9.2, fontweight="bold", color=C_TEXT, zorder=5)
        ax.plot([xs[i], xs[i]], [life_top, life_bot], color=C_LIFE,
                linewidth=1.1, linestyle=(0, (2.5, 2.2)), zorder=1)
        ax.add_patch(Rectangle((xs[i] - 0.045, life_bot), 0.09,
                               life_top - life_bot, facecolor="#F2F8FC",
                               edgecolor="none", zorder=0))

    y = head_y - 0.95
    for msg in messages:
        src, dst, text = msg[0], msg[1], msg[2]
        kind = msg[3] if len(msg) > 3 else "call"
        x1, x2 = xs[src], xs[dst]
        if kind == "self":
            ax.annotate(
                "",
                xy=(x1 + 0.02, y - 0.22),
                xytext=(x1 + 0.02, y),
                arrowprops=dict(arrowstyle="-|>", color=C_ARROW, lw=1.2,
                                connectionstyle="bar,fraction=-0.35"),
            )
            ax.text(x1 + 0.22, y - 0.08, text, ha="left", va="center",
                    fontsize=8.2, color=C_TEXT)
            y -= 0.58
            continue
        style = "->" if kind != "reply" else "->"
        ls = (0, (3, 2)) if kind == "reply" else "solid"
        ax.annotate(
            "",
            xy=(x2, y),
            xytext=(x1, y),
            arrowprops=dict(arrowstyle=style, color=C_ARROW, lw=1.25,
                            linestyle=ls),
        )
        mx = (x1 + x2) / 2
        ax.text(mx, y + 0.08, text, ha="center", va="bottom",
                fontsize=8.2, color=C_TEXT)
        y -= 0.52

    if note:
        ax.text(width / 2, 0.22, note, ha="center", va="center",
                fontsize=8.2, color="#666666")

    fig.tight_layout(pad=0.3)
    os.makedirs(os.path.dirname(outfile) or ".", exist_ok=True)
    fig.savefig(outfile, bbox_inches="tight", facecolor="white")
    plt.close(fig)


def _box(box_id, title, subtitle, color, x, y, w, h, ts=11.2, ss=8.4) -> Box:
    return Box(box_id, title, subtitle, color, x, y, w, h, ts, ss)


def build_user_client_overall(out: str) -> None:
    layers = [
        Layer("界面层", [
            _box("login", "LoginDialog", "登录 / 注册", C_UI, 1.55, 6.85, 3.15, 1.15),
            _box("main", "MainWindow", "底栏：充电站 / 充电 / 我的", C_UI, 5.15, 6.85, 7.35, 1.15),
        ]),
        Layer("业务子模块", [
            _box("acct", "账号管理与登录", "登录 · 注册 · 会话\n登出", C_BIZ, 1.45, 4.85, 3.35, 1.28),
            _box("svc", "用户服务", "定位 · 找站 · 导航 · 选桩\n预约 · 充电 · 个人中心", C_BIZ, 5.05, 4.85, 4.15, 1.28),
            _box("pay", "支付业务", "钱包充值\n充电记录", C_BIZ, 9.45, 4.85, 3.05, 1.28),
        ]),
        Layer("支撑与接口", [
            _box("loc", "LocationProvider", "定位辅助", C_SUP, 1.55, 2.95, 3.15, 1.12),
            _box("api", "ServerApiClient", "TCP API 接口", C_SUP, 5.25, 2.95, 3.75, 1.12),
            _box("model", "Models / FramedJson", "数据模型与帧编解码", C_MODEL, 9.35, 2.95, 3.15, 1.12),
        ]),
        Layer("服务端", [
            _box("srv", "admin_server  ·  TCP :9000", "", C_SERVER, 3.55, 1.15, 6.3, 0.95, 12.0),
        ]),
    ]
    arrows = [
        Arrow("login", "acct"),
        Arrow("main", "svc"),
        Arrow("main", "pay"),
        Arrow("acct", "api"),
        Arrow("svc", "loc"),
        Arrow("svc", "api"),
        Arrow("pay", "api"),
        Arrow("api", "model"),
        Arrow("api", "srv", bidir=True, label="TCP/JSON"),
    ]
    draw_architecture("图 3-1  user_client 模块结构图", layers, arrows, out,
                      figsize=(13.4, 9.8),
                      caption="界面不直连数据库；业务经 ServerApiClient 统一出站，定位仅服务「找站」")


def build_user_account(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("a", "登录页", "手机号 + 密码", C_UI, 1.6, 5.55, 3.1, 1.05),
            _box("b", "注册页", "手机号 + 密码 + 昵称", C_UI, 5.15, 5.55, 3.3, 1.05),
            _box("c", "登出入口", "MainWindow 侧/个人中心", C_UI, 8.85, 5.55, 3.15, 1.05),
        ]),
        Layer("窗体", [
            _box("dlg", "LoginDialog", "QStackedWidget 承载登录/注册", C_UI, 3.55, 3.85, 6.3, 1.05),
        ]),
        Layer("接口", [
            _box("api", "ServerApiClient", "phoneLogin / registerUser / logout", C_SUP, 3.55, 2.15, 6.3, 1.05),
        ]),
    ]
    arrows = [
        Arrow("a", "dlg"),
        Arrow("b", "dlg"),
        Arrow("c", "api"),
        Arrow("dlg", "api"),
    ]
    draw_architecture("图 3-1a  账号管理与登录子模块", layers, arrows, out,
                      figsize=(13.0, 7.4))


def build_user_service(out: str) -> None:
    layers = [
        Layer("界面功能", [
            _box("s1", "附近电站", "列表 / 筛选 / 距离", C_UI, 1.45, 6.55, 2.7, 1.0, 10.5, 8.0),
            _box("s2", "电站导航", "外部地图坐标", C_UI, 4.35, 6.55, 2.5, 1.0, 10.5, 8.0),
            _box("s3", "电桩预约收藏", "筛选 · 15 分钟锁桩", C_UI, 7.05, 6.55, 2.7, 1.0, 10.5, 8.0),
            _box("s4", "充电 / 个人中心", "进度 · 资料 · 余额", C_UI, 9.95, 6.55, 2.7, 1.0, 10.5, 8.0),
        ]),
        Layer("内部功能", [
            _box("locf", "定位服务", "GeoClue → IP 兜底", C_BIZ, 1.7, 4.7, 4.7, 1.1),
            _box("rec", "断线重连 / 会话恢复", "恢复预约与进行中订单", C_BIZ, 7.0, 4.7, 5.35, 1.1),
        ]),
        Layer("支撑", [
            _box("lp", "LocationProvider", "定位实现", C_SUP, 1.7, 2.85, 4.7, 1.0),
            _box("api", "ServerApiClient", "stations / piles / reservation / charge / user", C_SUP, 7.0, 2.85, 5.35, 1.0, 10.5, 8.0),
        ]),
    ]
    arrows = [
        Arrow("s1", "locf"),
        Arrow("s2", "api"),
        Arrow("s3", "api"),
        Arrow("s4", "api"),
        Arrow("s4", "rec"),
        Arrow("locf", "lp"),
        Arrow("rec", "api"),
        Arrow("s1", "api"),
    ]
    draw_architecture("图 3-1b  用户服务子模块", layers, arrows, out,
                      figsize=(13.4, 8.4))


def build_user_pay(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("w", "钱包充值页", "自定义金额 + 快捷面额", C_UI, 1.8, 4.9, 4.7, 1.15),
            _box("o", "充电记录页", "订单号 / 站点 / 电量 / 金额 / 状态", C_UI, 7.05, 4.9, 4.9, 1.15),
        ]),
        Layer("接口", [
            _box("api", "ServerApiClient", "wallet.recharge  /  orders.list", C_SUP, 3.55, 2.7, 6.5, 1.1),
        ]),
    ]
    arrows = [Arrow("w", "api"), Arrow("o", "api")]
    draw_architecture("图 3-1c  支付业务子模块", layers, arrows, out,
                      figsize=(13.0, 6.8))


def build_admin_overall(out: str) -> None:
    layers = [
        Layer("界面层", [
            _box("login", "LoginDialog", "登录 / 邀请码注册", C_UI, 1.5, 6.85, 3.2, 1.12),
            _box("main", "MainWindow",
                 "侧栏 7 页 + 当前管理员\n夜间模式开关 · 退出登录",
                 C_UI, 5.05, 6.85, 7.5, 1.12, 11.0, 8.1),
        ]),
        Layer("业务子模块", [
            _box("acct", "账号管理与登录", "登录 · 邀请码注册\n会话 token · 登出", C_BIZ, 1.35, 4.78, 2.7, 1.32, 10.2, 7.9),
            _box("fin", "财务管理", "今日/本月/总营收\n7/30 日折线 · 近单", C_BIZ, 4.25, 4.78, 2.7, 1.32, 10.2, 7.9),
            _box("ops", "运营监控", "桩/站查询与管理\n预约 · 用户 · 权限", C_BIZ, 7.15, 4.78, 2.7, 1.32, 10.2, 7.9),
            _box("ui", "界面美化", "侧栏换页 · 昼夜主题\n图表/表格同步换色", C_BIZ, 10.05, 4.78, 2.7, 1.32, 10.2, 7.9),
        ]),
        Layer("支撑与接口", [
            _box("api", "AdminApiClient", "TCP API · token · NEED_FORCE", C_SUP, 1.5, 2.92, 4.55, 1.1, 10.6, 8.1),
            _box("style", "StyleHelper", "浅色 / 深色样式表", C_MODEL, 6.3, 2.92, 2.85, 1.1, 10.6, 8.1),
            _box("model", "Models / FramedJson", "结构体与帧协议", C_MODEL, 9.4, 2.92, 3.25, 1.1, 10.6, 8.1),
        ]),
        Layer("服务端", [
            _box("srv", "admin_server  ·  TCP :9000", "dispatch → 鉴权 → 权限点 → DatabaseManager",
                 C_SERVER, 3.2, 1.12, 7.2, 1.0, 11.5, 8.2),
        ]),
    ]
    arrows = [
        Arrow("login", "acct"),
        Arrow("main", "acct"),
        Arrow("main", "fin"),
        Arrow("main", "ops"),
        Arrow("main", "ui"),
        Arrow("acct", "api"),
        Arrow("fin", "api"),
        Arrow("ops", "api"),
        Arrow("ui", "style"),
        Arrow("api", "model"),
        Arrow("api", "srv", bidir=True, label="TCP/JSON"),
    ]
    draw_architecture(
        "图 3-3  admin_client 模块结构图",
        layers,
        arrows,
        out,
        figsize=(13.4, 9.8),
        caption="分类对齐需求表：账号 / 财务运维 / 运营监控 / 界面美化；页数与权限以代码为准（侧栏 7 页）",
    )


def build_admin_account(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("a", "登录页", "账号 + 密码", C_UI, 1.55, 5.55, 3.15, 1.05),
            _box("b", "注册页", "账号 + 密码 + 姓名 + 邀请码", C_UI, 5.05, 5.55, 3.7, 1.05, 10.8, 8.0),
            _box("c", "登出入口", "侧栏「退出登录」", C_UI, 9.1, 5.55, 3.0, 1.05),
        ]),
        Layer("窗体", [
            _box("dlg", "LoginDialog", "邀请码决定角色 operator / auditor", C_UI, 3.4, 3.85, 6.6, 1.05),
        ]),
        Layer("接口", [
            _box("api", "AdminApiClient", "admin.login / admin.register / admin.logout", C_SUP, 3.4, 2.15, 6.6, 1.05, 10.8, 8.2),
        ]),
    ]
    arrows = [Arrow("a", "dlg"), Arrow("b", "dlg"), Arrow("c", "api"), Arrow("dlg", "api")]
    draw_architecture("图 3-3a  账号管理与登录子模块", layers, arrows, out,
                      figsize=(13.0, 7.4),
                      caption="无有效邀请码不能注册；账号重复返回 ACCOUNT_EXISTS；token 12 小时")


def build_admin_finance(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("kpi", "营收 KPI", "今日 / 本月 / 总营收", C_UI, 1.55, 5.35, 3.5, 1.15, 11.0, 8.1),
            _box("chart", "营收趋势图", "近 7 日 / 近 30 日折线", C_UI, 5.25, 5.35, 3.6, 1.15, 11.0, 8.1),
            _box("ord", "最近订单表", "订单号 / 用户 / 站点 / 金额", C_UI, 9.05, 5.35, 3.5, 1.15, 10.8, 8.0),
        ]),
        Layer("业务", [
            _box("biz", "财务运维", "dashboard.read\nQt Charts 本地绘制，协议只传数值", C_BIZ, 3.55, 3.55, 6.5, 1.15, 11.0, 8.1),
        ]),
        Layer("接口", [
            _box("api", "AdminApiClient", "admin.dashboard  {days: 7 | 30}", C_SUP, 3.55, 1.9, 6.5, 1.05, 10.8, 8.2),
        ]),
    ]
    arrows = [Arrow("kpi", "biz"), Arrow("chart", "biz"), Arrow("ord", "biz"), Arrow("biz", "api")]
    draw_architecture("图 3-3b  财务运维子模块", layers, arrows, out,
                      figsize=(13.2, 7.6),
                      caption="对应侧栏「销售业绩」页；buildDashboardPage + refreshDashboard")


def build_admin_ops(out: str) -> None:
    layers = [
        Layer("查询与管理页", [
            _box("ps", "电桩状态", "饼图 · 分布 · 关键字明细", C_UI, 1.4, 6.55, 3.7, 1.05, 10.4, 7.9),
            _box("pm", "充电桩管理", "城区→站点→状态 · CRUD\n故障桩模拟维修", C_UI, 5.3, 6.55, 3.7, 1.05, 10.4, 7.8),
            _box("sm", "充电站管理", "站名/地址检索 · 主从表\n增改删（占用需强制）", C_UI, 9.2, 6.55, 3.4, 1.05, 10.2, 7.8),
        ]),
        Layer("用户与预约页", [
            _box("um", "用户管理", "手机号查询 · 冻结/解冻\n查看充电记录", C_UI, 1.4, 4.85, 3.7, 1.1, 10.4, 7.9),
            _box("rm", "预约管理", "有效预约列表\n解除后桩回空闲", C_UI, 5.3, 4.85, 3.7, 1.1, 10.4, 7.9),
            _box("pm2", "权限管理", "邀请码发放\noperator / auditor 矩阵", C_UI, 9.2, 4.85, 3.4, 1.1, 10.2, 7.8),
        ]),
        Layer("接口", [
            _box("api", "AdminApiClient",
                 "piles.*  stations.*  users.*  reservations.*  invites.*  permissions.*",
                 C_SUP, 2.3, 3.05, 8.8, 1.05, 10.2, 7.9),
        ]),
    ]
    arrows = [
        Arrow("ps", "api"), Arrow("pm", "api"), Arrow("sm", "api"),
        Arrow("um", "api"), Arrow("rm", "api"), Arrow("pm2", "api"),
    ]
    draw_architecture("图 3-3c  运营监控子模块", layers, arrows, out,
                      figsize=(13.4, 8.6),
                      caption="需求表中的电桩/电站/预约/用户均归本模块；权限页为代码实有、需求表未单列")


def build_admin_ui(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("nav", "侧栏导航", "7 页 QListWidget + QStackedWidget\n切页按需 refresh*", C_UI, 1.5, 5.35, 5.4, 1.22, 10.6, 8.0),
            _box("theme", "昼夜模式", "QSettings 记住选择\n图表与表格同步换色", C_UI, 7.2, 5.35, 5.3, 1.22, 10.6, 8.0),
        ]),
        Layer("样式", [
            _box("sh", "StyleHelper", "adminClientStyle / adminClientDarkStyle", C_MODEL, 3.55, 3.55, 6.5, 1.1, 10.8, 8.1),
        ]),
        Layer("宿主", [
            _box("mw", "MainWindow", "侧栏展示姓名与 role，不访问数据库", C_UI, 3.55, 1.9, 6.5, 1.05, 10.8, 8.1),
        ]),
    ]
    arrows = [Arrow("nav", "mw"), Arrow("theme", "sh"), Arrow("sh", "mw")]
    draw_architecture("图 3-3d  界面美化子模块", layers, arrows, out,
                      figsize=(13.2, 7.6),
                      caption="不经 AdminApiClient；需求表写「五页」，代码侧栏为七页（含预约管理、权限管理）")


def build_sequences(outdir: str) -> None:
    draw_sequence(
        "图 3-4a  管理员登录 / 邀请码注册",
        ["管理员", "LoginDialog", "AdminApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "输入账号密码 或 填写邀请码"),
            (1, 2, "loginAdmin / registerAdmin"),
            (2, 3, "admin.login / admin.register  + 帧 JSON"),
            (3, 4, "loginAdmin 或 校验邀请码并 insert admin"),
            (4, 3, "Admin{id, role, ...}", "reply"),
            (3, 3, "签发 UUID token，写入 m_adminSessions", "self"),
            (3, 2, "ok + token + admin", "reply"),
            (2, 1, "缓存 token，返回 Admin", "reply"),
            (1, 0, "关闭登录窗，打开 MainWindow", "reply"),
        ],
        os.path.join(outdir, "fig_3_4a_admin_login.png"),
        note="注册消耗邀请码且不可复用；登录失败不创建账号。token 有效期 12 小时。",
    )
    draw_sequence(
        "图 3-4b  财务运维刷新（销售业绩）",
        ["管理员", "MainWindow", "AdminApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "打开「销售业绩」或点刷新"),
            (1, 2, "dashboard(7 或 30)"),
            (2, 3, "admin.dashboard"),
            (3, 3, "authorizedAdmin + dashboard.read", "self"),
            (3, 4, "salesStats / dailySales / 最近订单"),
            (4, 3, "KPI 与日营收序列", "reply"),
            (3, 2, "ok + data", "reply"),
            (1, 1, "Qt Charts 本地绘制折线", "self"),
            (1, 0, "更新 KPI、折线与近单表", "reply"),
        ],
        os.path.join(outdir, "fig_3_4b_admin_monitor.png"),
        note="对应侧栏「销售业绩」。图表不在服务端生成，协议只传 KPI 与日营收数值。",
    )
    draw_sequence(
        "图 3-4c  电桩/电站删除（占用保护与强制删除）",
        ["管理员", "MainWindow", "AdminApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "选择行并确认删除"),
            (1, 2, "deletePile/Station(id, force=false)"),
            (2, 3, "admin.*.delete  {force:false}"),
            (3, 3, "校验 piles.write / stations.write", "self"),
            (3, 4, "deletePile/Station(force=false)"),
            (4, 3, "若占用：IN_USE:原因", "reply"),
            (3, 2, "code=NEED_FORCE", "reply"),
            (1, 0, "二次确认「强制删除」对话框"),
            (0, 1, "确认强制"),
            (1, 2, "deletePile/Station(id, force=true)"),
            (2, 3, "admin.*.delete  {force:true}"),
            (3, 4, "取消预约/停单后物理删除"),
            (4, 3, "成功", "reply"),
            (3, 2, "ok", "reply"),
            (1, 0, "刷新桩/站/状态三页", "reply"),
        ],
        os.path.join(outdir, "fig_3_4c_admin_force_delete.png"),
        note="强制删除是显式破坏性操作：第一次失败给出原因，第二次才允许带 force。",
    )
    draw_sequence(
        "图 3-4d  权限变更与邀请码发放",
        ["系统管理员", "权限管理页", "AdminApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "选择角色 operator/auditor，勾选权限"),
            (1, 2, "setPermission(role, key, allowed)"),
            (2, 3, "admin.permissions.set"),
            (3, 3, "必须具备 permissions.write；拒绝改 admin 角色", "self"),
            (3, 4, "UPSERT role_permissions + 写审计"),
            (4, 3, "成功", "reply"),
            (0, 1, "选择授予角色并生成邀请码"),
            (1, 2, "createInviteCode(role)"),
            (2, 3, "admin.invites.create"),
            (3, 4, "insert invite_codes，返回明文码"),
            (4, 3, "code", "reply"),
            (1, 0, "对话框展示一次性邀请码", "reply"),
        ],
        os.path.join(outdir, "fig_3_4d_admin_permission.png"),
        note="后续登录按最新权限矩阵生效；客户端不在本地缓存权限，每次写操作都由服务端判定。",
    )
    draw_sequence(
        "图 3-2a  用户端账号登录（对照）",
        ["车主", "LoginDialog", "ServerApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "11 位手机号 + 密码"),
            (1, 2, "phoneLogin"),
            (2, 3, "user.phoneLogin"),
            (3, 4, "loginByPhone：不存在则失败，不自动注册"),
            (4, 3, "User 或错误", "reply"),
            (3, 2, "ok + token + user", "reply"),
            (1, 0, "进入 MainWindow", "reply"),
        ],
        os.path.join(outdir, "fig_3_2a_user_login.png"),
    )
    draw_sequence(
        "图 3-2b  找站与选桩",
        ["车主", "MainWindow", "LocationProvider", "ServerApiClient", "admin_server"],
        [
            (0, 1, "打开充电站页 / 点击定位"),
            (1, 2, "requestCurrentLocation"),
            (2, 1, "经纬度（失败则北京默认点）", "reply"),
            (1, 3, "listStations(lat,lng,keyword,district)"),
            (3, 4, "stations.list"),
            (4, 3, "按距离排序的站点", "reply"),
            (0, 1, "选中站点"),
            (1, 3, "listPiles(stationId, speed, connector)"),
            (3, 4, "piles.list"),
            (4, 3, "站内电桩", "reply"),
        ],
        os.path.join(outdir, "fig_3_2b_user_find.png"),
    )
    draw_sequence(
        "图 3-2c  预约与充电",
        ["车主", "MainWindow", "ServerApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "对空闲桩预约"),
            (1, 2, "createReservation(pileId)"),
            (2, 3, "reservation.create"),
            (3, 4, "锁桩 15 分钟，校验并发上限"),
            (0, 1, "开始充电"),
            (1, 2, "startCharging"),
            (2, 3, "charge.start：校验余额并建单"),
            (1, 2, "updateChargingProgress（定时）"),
            (0, 1, "结束充电"),
            (1, 2, "stopCharging"),
            (3, 4, "结算扣款、释放电桩、写流水"),
        ],
        os.path.join(outdir, "fig_3_2c_user_charge.png"),
    )
    draw_sequence(
        "图 3-2d  充值与订单",
        ["车主", "个人中心", "ServerApiClient", "ApiDispatcher", "DatabaseManager"],
        [
            (0, 1, "输入充值金额"),
            (1, 2, "rechargeUser(amount)"),
            (2, 3, "wallet.recharge"),
            (3, 4, "余额与充值流水同一事务"),
            (4, 3, "新余额", "reply"),
            (0, 1, "刷新充电记录"),
            (1, 2, "listOrders"),
            (2, 3, "orders.list"),
            (3, 4, "按用户查询订单"),
            (1, 0, "表格展示中文状态", "reply"),
        ],
        os.path.join(outdir, "fig_3_2d_user_pay.png"),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="生成概要设计模块图 / 时序图")
    parser.add_argument(
        "--out",
        default="figures",
        help="输出目录（默认为本文件夹下的 figures）",
    )
    args = parser.parse_args()
    here = os.path.dirname(os.path.abspath(__file__))
    outdir = args.out if os.path.isabs(args.out) else os.path.join(here, args.out)
    os.makedirs(outdir, exist_ok=True)

    jobs = [
        ("fig_3_1_user_client.png", build_user_client_overall),
        ("fig_3_1a_user_account.png", build_user_account),
        ("fig_3_1b_user_service.png", build_user_service),
        ("fig_3_1c_user_pay.png", build_user_pay),
        ("fig_3_3_admin_client.png", build_admin_overall),
        ("fig_3_3a_admin_account.png", build_admin_account),
        ("fig_3_3b_admin_finance.png", build_admin_finance),
        ("fig_3_3c_admin_ops.png", build_admin_ops),
        ("fig_3_3d_admin_ui.png", build_admin_ui),
    ]
    print(f"字体：{FONT}")
    print(f"输出：{outdir}")
    for name, fn in jobs:
        path = os.path.join(outdir, name)
        fn(path)
        print(f"  写入 {name}")
    build_sequences(outdir)
    print("  写入时序图 fig_3_2* / fig_3_4*")
    print("完成。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
