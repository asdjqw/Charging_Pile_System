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
        if s1 in ("e", "w") and s2 in ("e", "w"):
            my += 0.16 + spec.rad * 0.2
            ha, va = "center", "bottom"
        else:
            mx += 0.38
            my += 0.02
            ha, va = "left", "center"
        ax.text(
            mx,
            my,
            spec.label,
            ha=ha,
            va=va,
            fontsize=7.4,
            color=C_ARROW,
            fontweight="bold",
            zorder=8,
            linespacing=1.15,
            bbox=dict(facecolor="white", edgecolor="none", pad=0.6, alpha=0.88),
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
    bw, bh = 1.90, 0.62
    # 生命线贴边时，最右参与者方框会超出 xlim，导出后右半截断。
    left_m = bw / 2 + 0.50
    right_m = bw / 2 + 0.70
    width = max(12.6, left_m + 2.65 * max(n - 1, 1) + right_m)
    height = max(6.0, 1.70 + 0.52 * rows + (0.50 if note else 0))
    fig, ax = plt.subplots(figsize=(width, height), dpi=160)
    fig.patch.set_facecolor("white")
    ax.set_xlim(0, width)
    ax.set_ylim(0, height)
    ax.set_axis_off()
    ax.set_clip_on(False)

    ax.text(width / 2, height - 0.32, title, ha="center", va="center",
            fontsize=14.5, fontweight="bold", color=C_TITLE, clip_on=False)

    xs = [left_m + i * (width - left_m - right_m) / max(n - 1, 1) for i in range(n)]
    head_y = height - 0.95
    life_top = head_y - 0.42
    life_bot = 0.55 if note else 0.35

    for i, name in enumerate(actors):
        box = FancyBboxPatch(
            (xs[i] - bw / 2, head_y - bh / 2),
            bw,
            bh,
            boxstyle="round,pad=0.01,rounding_size=0.08",
            linewidth=1.1,
            edgecolor=C_EDGE,
            facecolor=C_ACTOR,
            zorder=4,
            clip_on=False,
        )
        ax.add_patch(box)
        ax.text(xs[i], head_y, name, ha="center", va="center",
                fontsize=9.2, fontweight="bold", color=C_TEXT, zorder=5,
                clip_on=False)
        ax.plot([xs[i], xs[i]], [life_top, life_bot], color=C_LIFE,
                linewidth=1.1, linestyle=(0, (2.5, 2.2)), zorder=1,
                clip_on=False)
        ax.add_patch(Rectangle((xs[i] - 0.045, life_bot), 0.09,
                               life_top - life_bot, facecolor="#F2F8FC",
                               edgecolor="none", zorder=0, clip_on=False))

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
                annotation_clip=False,
            )
            ax.text(x1 + 0.22, y - 0.08, text, ha="left", va="center",
                    fontsize=8.2, color=C_TEXT, clip_on=False)
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
            annotation_clip=False,
        )
        mx = (x1 + x2) / 2
        ax.text(mx, y + 0.08, text, ha="center", va="bottom",
                fontsize=8.2, color=C_TEXT, clip_on=False)
        y -= 0.52

    if note:
        ax.text(width / 2, 0.22, note, ha="center", va="center",
                fontsize=8.2, color="#666666", clip_on=False)

    os.makedirs(os.path.dirname(outfile) or ".", exist_ok=True)
    # tight_layout 会再压一圈坐标轴，最右列容易再次被裁。
    fig.savefig(outfile, bbox_inches="tight", pad_inches=0.28, facecolor="white")
    plt.close(fig)


def _box(box_id, title, subtitle, color, x, y, w, h, ts=11.2, ss=8.4) -> Box:
    return Box(box_id, title, subtitle, color, x, y, w, h, ts, ss)


def _line(ax, x1, y1, x2, y2, arrow=True) -> None:
    ax.annotate(
        "",
        xy=(x2, y2),
        xytext=(x1, y1),
        arrowprops=dict(
            arrowstyle="-|>" if arrow else "-",
            color=C_ARROW,
            lw=1.15,
            shrinkA=0,
            shrinkB=0.5,
        ),
        zorder=5,
    )


def draw_admin_ops_calls(outfile: str) -> None:
    """运营监控：页面 → MainWindow 函数互调 → AdminApiClient 各方法。"""
    fig_w, fig_h = 15.4, 12.2
    fig, ax = plt.subplots(figsize=(fig_w, fig_h), dpi=160)
    fig.patch.set_facecolor("white")
    ax.set_xlim(0, 15.0)
    ax.set_ylim(0, 11.55)
    ax.set_aspect("equal")
    ax.axis("off")

    ax.text(7.5, 11.22, "图 3-2-1b  运营监控子模块", ha="center", va="center",
            fontsize=15.5, fontweight="bold", color=C_TITLE, zorder=20)
    ax.text(0.12, 10.46, "界面", ha="left", va="center", fontsize=10.5,
            fontweight="bold", color=C_LABEL)
    ax.text(0.12, 7.40, "MainWindow\n函数", ha="left", va="center", fontsize=9.2,
            fontweight="bold", color=C_LABEL)
    ax.text(0.12, 1.55, "接口", ha="left", va="center", fontsize=10.5,
            fontweight="bold", color=C_LABEL)

    xs = [1.10, 3.68, 6.26, 8.84, 11.42]
    pw = 2.42
    pages = [
        ("电桩状态页", "进入页 / 关键字回车"),
        ("充电桩管理", "筛选变化 / 增删改 / 重启"),
        ("电站管理", "检索 / 点行 / 增删改"),
        ("预约管理", "进入页 / 解除"),
        ("用户管理", "查询 / 冻结 / 看订单"),
    ]
    page_y, page_h = 10.00, 0.92
    for i, (t, s) in enumerate(pages):
        _round_box(ax, Box(f"p{i}", t, s, C_UI, xs[i], page_y, pw, page_h, 10.0, 7.4))

    # 每列函数：(title, subtitle, height)
    cols = [
        [
            ("refreshPileStatus()", "pileStats()\nlistPiles(-1)\n关键字本端过滤"),
        ],
        [
            ("onPileDistrictChanged()", "先 rebuildPileStationFilter\n再 refreshPiles"),
            ("refreshPiles()", "districts() + listPiles()\n内调 rebuildPileStationFilter\n→ listStations() 填下拉"),
            ("onAddPile / onEditPile()", "editPileDialog → savePile()\n再 refreshPiles/Status/Stations"),
            ("onDeletePile()", "deletePile(false) → confirmForce\n→ deletePile(true) → 三页 refresh"),
            ("onRestartPile()", "restartPile()；1.8s 后再\nrefreshPiles + refreshPileStatus"),
        ],
        [
            ("refreshStations()", "listStations(关键字)"),
            ("onStationRowClicked()", "listStationPiles(id)"),
            ("onAdd / onEditStation()", "对话框 → saveStation()\n再 refreshStations/Piles"),
            ("onDeleteStation()", "deleteStation + confirmForce\n再三页 refresh"),
        ],
        [
            ("refreshReservations()", "listReservations()"),
            ("onCancelReservation()", "cancelReservation(id)\n再 refresh 预约/桩/状态"),
        ],
        [
            ("refreshUsers()", "listUsers(关键字)"),
            ("onToggleUserStatus()", "setUserStatus()"),
            ("onViewUserOrders()", "listUserOrders()\n可选 deleteOrder()"),
        ],
    ]
    fn_h = 0.78
    gap = 0.11
    fn_top = page_y - 0.18
    fn_boxes: List[List[Box]] = []
    for c, items in enumerate(cols):
        col_boxes: List[Box] = []
        y = fn_top - fn_h
        for j, (t, s) in enumerate(items):
            h = 0.92 if "\n" in s and s.count("\n") >= 2 else fn_h
            if t.startswith("onDelete"):
                h = 1.00
            b = Box(f"f{c}_{j}", t, s, C_BIZ, xs[c], y - h + fn_h, pw, h, 8.5, 6.8)
            _round_box(ax, b)
            col_boxes.append(b)
            y = b.y - gap - fn_h
        fn_boxes.append(col_boxes)

    # 同列函数互调（自上而下）
    for col_boxes in fn_boxes:
        for a, b in zip(col_boxes, col_boxes[1:]):
            x1, y1 = _anchor(a, "s")
            x2, y2 = _anchor(b, "n")
            _line(ax, x1, y1, x2, y2)

    # 页 → 该列第一个函数
    for i, col_boxes in enumerate(fn_boxes):
        x1, y1 = xs[i] + pw / 2, page_y
        x2, y2 = _anchor(col_boxes[0], "n")
        _line(ax, x1, y1, x2, y2)

    # AdminApiClient 统一框：端口在上沿，标题在下沿，避免竖线穿过标题
    api_x, api_y, api_w, api_h = 1.10, 0.38, 12.74, 2.42
    api_box = Box("api", "", "", C_SUP, api_x, api_y, api_w, api_h, 11.0, 8.0)
    _round_box(ax, api_box)
    ax.text(api_x + api_w / 2, api_y + 0.20, "AdminApiClient（统一出站，各方法互不调用）",
            ha="center", va="center", fontsize=10.6, fontweight="bold", color=C_TEXT, zorder=6)

    ports = [
        "pileStats", "listPiles", "districts", "listStations", "savePile",
        "deletePile", "restartPile", "saveStation", "deleteStation", "listStationPiles",
        "listReservations", "cancelReservation", "listUsers", "setUserStatus", "listUserOrders",
    ]
    port_w, port_h = 2.30, 0.42
    port_gap_x, port_gap_y = 0.16, 0.10
    port_origin_x = api_x + 0.22
    port_pos = []
    for i, name in enumerate(ports):
        r, c = divmod(i, 5)
        px = port_origin_x + c * (port_w + port_gap_x)
        py = api_y + api_h - 0.16 - port_h - r * (port_h + port_gap_y)
        pb = Box(f"pt{i}", name, "", "#F8C9A3", px, py, port_w, port_h, 8.0, 7.0)
        _round_box(ax, pb)
        port_pos.append(pb)

    rail_y = api_y + api_h + 0.20
    calls = [
        (fn_boxes[0][0], ["pileStats", "listPiles"]),
        (fn_boxes[1][1], ["districts", "listPiles", "listStations"]),
        (fn_boxes[1][2], ["savePile"]),
        (fn_boxes[1][3], ["deletePile"]),
        (fn_boxes[1][4], ["restartPile"]),
        (fn_boxes[2][0], ["listStations"]),
        (fn_boxes[2][1], ["listStationPiles"]),
        (fn_boxes[2][2], ["saveStation"]),
        (fn_boxes[2][3], ["deleteStation"]),
        (fn_boxes[3][0], ["listReservations"]),
        (fn_boxes[3][1], ["cancelReservation"]),
        (fn_boxes[4][0], ["listUsers"]),
        (fn_boxes[4][1], ["setUserStatus"]),
        (fn_boxes[4][2], ["listUserOrders"]),
    ]
    port_by_name = {p.title: p for p in port_pos}
    for src, names in calls:
        sx, sy = _anchor(src, "s")
        for name in names:
            pt = port_by_name[name]
            tx, ty = _anchor(pt, "n")
            ax.plot([sx, sx, tx, tx], [sy, rail_y, rail_y, ty],
                    color=C_ARROW, lw=1.05, zorder=4)
            ax.annotate("", xy=(tx, ty), xytext=(tx, rail_y),
                        arrowprops=dict(arrowstyle="-|>", color=C_ARROW, lw=1.05),
                        zorder=5)

    ax.text(7.5, 0.18,
            "实线：同列函数互调，并落到 AdminApiClient 对应方法。虚线：写操作成功后回刷其它页的 refresh*。字在格子里，线上不写字。",
            ha="center", va="center", fontsize=8.2, color="#666666")

    fig.subplots_adjust(left=0.02, right=0.99, top=0.97, bottom=0.03)
    os.makedirs(os.path.dirname(outfile) or ".", exist_ok=True)
    fig.savefig(outfile, bbox_inches="tight", pad_inches=0.26, facecolor="white")
    plt.close(fig)


def draw_pipeline(
    title: str,
    col_headers: Sequence[str],
    flows: Sequence[dict],
    outfile: str,
    caption: str = "",
) -> None:
    """
    从左到右画一条或多条代码链路。
    每个 flow:
      name  — 左侧流程名
      cells — 与列头等长，每格 (标题, 说明)
      data  — 相邻列之间的数据/动作标签
    """
    n_row = len(flows)
    name_w = 1.22
    left = 1.42
    col_w = 2.28
    gap_x = 0.20
    box_h = 1.26
    row_gap = 0.64
    top = 0.62 + n_row * (box_h + row_gap)
    fig_w = 14.6
    fig_h = max(8.6, top + 1.45)

    fig, ax = plt.subplots(figsize=(fig_w, fig_h), dpi=160)
    fig.patch.set_facecolor("white")
    ax.set_xlim(0, 14.4)
    ax.set_ylim(0, fig_h)
    ax.set_aspect("equal")
    ax.axis("off")

    ax.text(7.2, fig_h - 0.36, title, ha="center", va="center",
            fontsize=15.2, fontweight="bold", color=C_TITLE, zorder=20, clip_on=False)

    header_y = top + 0.10
    colors = [C_UI, C_SUP, C_BIZ, C_SERVER, C_MODEL]
    ax.text(0.08 + name_w / 2, header_y, "代码路径", ha="center", va="bottom",
            fontsize=9.0, fontweight="bold", color=C_LABEL)
    for i, header in enumerate(col_headers):
        cx = left + i * (col_w + gap_x) + col_w / 2
        ax.text(cx, header_y, header, ha="center", va="bottom",
                fontsize=9.2, fontweight="bold", color=C_LABEL)

    def _wrap_lab(text: str) -> str:
        if not text or len(text) <= 9:
            return text
        for sep in (" / ", " · ", "+", "|"):
            if sep in text:
                return text.replace(sep, "\n", 1)
        return text[:8] + "\n" + text[8:]

    for r, flow in enumerate(flows):
        y = top - (r + 1) * (box_h + row_gap) + row_gap
        name_box = Box(f"{r}_name", flow["name"], "", C_BIZ, 0.08, y, name_w, box_h, 8.6, 7.2)
        _round_box(ax, name_box)
        boxes: List[Box] = []
        for i, cell in enumerate(flow["cells"]):
            ct, cs = cell if isinstance(cell, tuple) else (cell, "")
            b = Box(
                f"{r}_{i}", ct, cs, colors[i % len(colors)],
                left + i * (col_w + gap_x), y, col_w, box_h, 9.1, 7.3,
            )
            _round_box(ax, b)
            boxes.append(b)
        labels = flow.get("data", [])
        for i, lab in enumerate(labels):
            if i + 1 >= len(boxes):
                break
            a, b = boxes[i], boxes[i + 1]
            x1, y1 = _anchor(a, "e")
            x2, y2 = _anchor(b, "w")
            ax.annotate(
                "",
                xy=(x2, y2),
                xytext=(x1, y1),
                arrowprops=dict(arrowstyle="-|>", color=C_ARROW, lw=1.25),
            )
            ax.text(
                (x1 + x2) / 2,
                y1 + 0.16,
                _wrap_lab(lab),
                ha="center",
                va="bottom",
                fontsize=6.9,
                color=C_ARROW,
                fontweight="bold",
                linespacing=1.15,
            )

    if caption:
        ax.text(7.0, 0.22, caption, ha="center", va="center",
                fontsize=8.3, color="#666666")

    fig.subplots_adjust(left=0.02, right=0.99, top=0.97, bottom=0.04)
    os.makedirs(os.path.dirname(outfile) or ".", exist_ok=True)
    fig.savefig(outfile, bbox_inches="tight", pad_inches=0.28, facecolor="white")
    plt.close(fig)


def build_system(out: str) -> None:
    layers = [
        Layer("表现层", [
            _box("uc", "user_client", "车主 UI\nServerApiClient 出站", C_UI, 1.7, 4.85, 4.5, 1.28, 11.2, 8.2),
            _box("ac", "admin_client", "运营 UI\nAdminApiClient 出站", C_UI, 7.0, 4.85, 4.5, 1.28, 11.2, 8.2),
        ]),
        Layer("服务层", [
            _box("srv", "admin_server", "唯一业务入口  ·  TCP :9000\n接收帧 JSON，完成校验与编排", C_SUP, 3.1, 2.85, 7.0, 1.22, 11.0, 8.1),
        ]),
        Layer("数据层", [
            _box("db", "SQLite", "站点 / 电桩 / 用户 / 订单等持久化\n仅服务层访问", C_MODEL, 3.1, 1.15, 7.0, 1.12, 11.0, 8.1),
        ]),
    ]
    arrows = [
        Arrow("uc", "srv", bidir=True, label="TCP/JSON"),
        Arrow("ac", "srv", bidir=True, label="TCP/JSON"),
        Arrow("srv", "db", bidir=True, label="SQL"),
    ]
    draw_architecture(
        "图 2-1  系统结构图",
        layers, arrows, out, figsize=(13.2, 7.8),
        caption="表现层不直连数据库。两端前端只发请求，业务校验与库访问集中在服务层。",
    )


def build_user_client_overall(out: str) -> None:
    layers = [
        Layer("界面层", [
            _box("login", "LoginDialog", "登录 / 注册", C_UI, 1.55, 5.15, 3.15, 1.15),
            _box("main", "MainWindow", "底栏：充电站 / 充电 / 我的", C_UI, 5.15, 5.15, 7.35, 1.15),
        ]),
        Layer("业务子模块", [
            _box("acct", "账号管理与登录", "登录 · 注册 · 会话\n登出", C_BIZ, 1.45, 3.15, 3.35, 1.28),
            _box("svc", "用户服务", "定位 · 找站 · 导航 · 选桩\n预约 · 充电 · 个人中心", C_BIZ, 5.05, 3.15, 4.15, 1.28),
            _box("pay", "支付业务", "钱包充值\n充电记录", C_BIZ, 9.45, 3.15, 3.05, 1.28),
        ]),
        Layer("支撑与接口", [
            _box("loc", "LocationProvider", "定位辅助", C_SUP, 1.55, 1.25, 3.15, 1.12),
            _box("api", "ServerApiClient", "TCP API 接口", C_SUP, 5.25, 1.25, 3.75, 1.12),
            _box("model", "Models / FramedJson", "数据模型与帧编解码", C_MODEL, 9.35, 1.25, 3.15, 1.12),
        ]),
    ]
    arrows = [
        Arrow("login", "acct", label="手机号+密码"),
        Arrow("main", "svc", label="位置/选站/选桩"),
        Arrow("main", "pay", label="金额/查单"),
        Arrow("acct", "api", label="token"),
        Arrow("svc", "loc", label="经纬度"),
        Arrow("svc", "api", label="站/桩/预约/充电"),
        Arrow("pay", "api", label="充值/订单"),
        Arrow("api", "model", label="编解码"),
    ]
    draw_architecture("图 3-1  user_client 模块结构图", layers, arrows, out,
                      figsize=(13.4, 8.2),
                      caption="三个业务子模块互不调用。定位只服务找站；出站统一走 ServerApiClient。")


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
    draw_architecture("图 3-1-1a  账号管理与登录子模块", layers, arrows, out,
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
    draw_architecture("图 3-1-1b  用户服务子模块", layers, arrows, out,
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
    draw_architecture("图 3-1-1c  支付业务子模块", layers, arrows, out,
                      figsize=(13.0, 6.8))


def build_admin_overall(out: str) -> None:
    layers = [
        Layer("界面层", [
            _box("login", "LoginDialog", "登录 / 注册窗体", C_UI, 1.5, 5.15, 3.2, 1.12),
            _box("main", "MainWindow",
                 "侧栏业务页 + 当前管理员\n夜间模式 · 退出登录",
                 C_UI, 5.05, 5.15, 7.5, 1.12, 11.0, 8.1),
        ]),
        Layer("业务子模块", [
            _box("acct", "账号管理与登录", "登录/登出 · 注册界面\n创建邀请码", C_BIZ, 1.35, 3.15, 2.7, 1.32, 10.2, 7.9),
            _box("ops", "运营监控", "电桩/电站/预约\n后台重启 · 用户", C_BIZ, 4.25, 3.15, 2.7, 1.32, 10.2, 7.9),
            _box("fin", "财务管理", "今日/本月/总营收\n7/30 日折线 · 近单", C_BIZ, 7.15, 3.15, 2.7, 1.32, 10.2, 7.9),
            _box("ui", "界面美化", "白天/夜间模式\n全页图表表格换色", C_BIZ, 10.05, 3.15, 2.7, 1.32, 10.2, 7.9),
        ]),
        Layer("支撑与接口", [
            _box("api", "AdminApiClient", "TCP 出站 · token · NEED_FORCE", C_SUP, 1.5, 1.25, 4.55, 1.1, 10.6, 8.1),
            _box("style", "StyleHelper", "浅色 / 深色样式表", C_MODEL, 6.3, 1.25, 2.85, 1.1, 10.6, 8.1),
            _box("model", "Models / FramedJson", "结构体与帧协议", C_MODEL, 9.4, 1.25, 3.25, 1.1, 10.6, 8.1),
        ]),
    ]
    arrows = [
        Arrow("login", "acct", label="账号密码 / 邀请码"),
        Arrow("main", "acct", label="退出 / 发码"),
        Arrow("main", "ops", label="筛选条件 / ID"),
        Arrow("main", "fin", label="days=7|30"),
        Arrow("main", "ui", label="darkMode"),
        Arrow("acct", "api", label="要 token"),
        Arrow("ops", "api", label="桩/站/用户/预约"),
        Arrow("fin", "api", label="dashboard"),
        Arrow("ui", "style", label="换 QSS"),
        Arrow("api", "model", label="编解码"),
    ]
    draw_architecture(
        "图 3-2  admin_client 模块结构图",
        layers, arrows, out, figsize=(13.4, 8.4),
        caption="四个业务模块互不调用。账号/运营/财务统一经 AdminApiClient 出站；界面美化只走 StyleHelper。",
    )


def build_admin_account(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("login", "登录页", "账号 + 密码\n空则本地拦截", C_UI, 1.35, 5.25, 2.55, 1.18, 10.4, 7.8),
            _box("reg", "注册页", "账号/密码/姓名\n+ 邀请码", C_UI, 4.05, 5.25, 2.55, 1.18, 10.4, 7.8),
            _box("out", "侧栏退出", "确认后回登录窗", C_UI, 6.75, 5.25, 2.45, 1.18, 10.4, 7.8),
            _box("perm", "权限页发码", "选 operator\n/ auditor", C_UI, 9.35, 5.25, 2.5, 1.18, 10.3, 7.7),
        ]),
        Layer("会话数据", [
            _box("sess", "m_token + Admin", "登录/注册写入\n侧栏读姓名/角色", C_MODEL, 2.15, 3.35, 4.15, 1.22, 10.8, 8.0),
            _box("code", "邀请码 code", "发码得到明文\n注册时一次性消耗", C_MODEL, 7.15, 3.35, 4.15, 1.22, 10.8, 8.0),
        ]),
        Layer("接口", [
            _box("api", "AdminApiClient",
                 "loginAdmin / registerAdmin / logout / createInviteCode",
                 C_SUP, 2.55, 1.35, 8.1, 1.12, 10.4, 7.9),
        ]),
    ]
    arrows = [
        Arrow("login", "api", label="账号密码"),
        Arrow("reg", "api", label="四字段"),
        Arrow("out", "api", label="token"),
        Arrow("perm", "api", label="role"),
        Arrow("api", "sess", label="token+Admin", rad=0.12),
        Arrow("sess", "out", label="清 token 回登录", rad=-0.18),
        Arrow("api", "code", label="明文 code", rad=-0.12),
        Arrow("code", "reg", label="注册消耗", rad=0.18),
    ]
    draw_architecture(
        "图 3-2-1a  账号管理与登录子模块",
        layers, arrows, out, figsize=(13.4, 8.0),
        caption="枢纽是会话数据：登录/注册写入 token，退出清掉；邀请码把发码页和注册页连在一起。",
    )


def build_admin_ops(out: str) -> None:
    draw_admin_ops_calls(out)


def build_admin_finance(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("page", "销售业绩页", "进入 / 刷新 / 切换 7 或 30 日", C_UI, 3.55, 6.85, 6.1, 1.12, 11.0, 8.1),
        ]),
        Layer("回写控件", [
            _box("kpi", "营收 KPI", "今日 / 本月 / 总营收", C_UI, 1.4, 5.05, 3.3, 1.12, 10.6, 7.9),
            _box("chart", "营收折线", "Qt Charts 本地绘图", C_UI, 4.95, 5.05, 3.3, 1.12, 10.6, 7.9),
            _box("ord", "最近订单表", "约 12 条 · 中文状态", C_UI, 8.5, 5.05, 3.3, 1.12, 10.6, 7.9),
        ]),
        Layer("数据对象", [
            _box("payload", "dashboard payload",
                 "stats · dailySales · recentOrders   （一份 JSON，三路拆开）",
                 C_MODEL, 2.55, 3.28, 8.1, 1.12, 10.6, 8.0),
        ]),
        Layer("接口", [
            _box("api", "AdminApiClient::dashboard", "一次请求  {days:7|30}\n返回 stats / dailySales / recentOrders",
                 C_SUP, 3.35, 1.25, 6.5, 1.15, 10.4, 7.9),
        ]),
    ]
    arrows = [
        Arrow("page", "api", label="days=7|30"),
        Arrow("api", "payload", label="三块数据"),
        Arrow("payload", "kpi", label="today/month/total"),
        Arrow("payload", "chart", label="dailySales[]"),
        Arrow("payload", "ord", label="recentOrders[]"),
        Arrow("page", "kpi", rad=0.12),
        Arrow("page", "chart"),
        Arrow("page", "ord", rad=-0.12),
    ]
    draw_architecture(
        "图 3-2-1c  财务管理子模块",
        layers, arrows, out, figsize=(13.4, 9.0),
        caption="枢纽是 dashboard payload：一次拉取，扇出到 KPI / 折线 / 近单。本页不查电桩。",
    )


def build_admin_ui(out: str) -> None:
    layers = [
        Layer("界面", [
            _box("sw", "侧栏昼夜开关", "onToggleDarkMode(bool)", C_UI, 4.15, 6.85, 4.9, 1.12, 11.0, 8.1),
        ]),
        Layer("本地处理", [
            _box("theme", "applyTheme", "qApp->setStyleSheet", C_BIZ, 1.5, 5.05, 4.55, 1.12, 10.6, 8.0),
            _box("set", "QSettings", "键 ui/darkMode\n下次启动读回", C_BIZ, 7.15, 5.05, 4.55, 1.12, 10.6, 8.0),
        ]),
        Layer("实现", [
            _box("sh", "StyleHelper", "浅色 / 深色 QSS", C_MODEL, 1.5, 3.28, 4.55, 1.12, 10.6, 8.0),
            _box("ch", "图表跟主题", "再调 refreshDashboard\n与 refreshPileStatus", C_MODEL, 7.15, 3.28, 4.55, 1.12, 10.4, 7.8),
        ]),
        Layer("回写", [
            _box("app", "全窗换色", "按钮文案同步 · 折线/饼图重绘", C_UI, 3.35, 1.25, 6.5, 1.12, 10.6, 8.0),
        ]),
    ]
    arrows = [
        Arrow("sw", "theme", label="dark"),
        Arrow("sw", "set", label="记住选择"),
        Arrow("theme", "sh", label="选 QSS"),
        Arrow("theme", "ch", label="换画笔"),
        Arrow("set", "theme", label="启动还原", rad=0.2),
        Arrow("sh", "app", label="样式表"),
        Arrow("ch", "app", label="重绘 Chart"),
    ]
    draw_architecture(
        "图 3-2-1d  界面美化子模块",
        layers, arrows, out, figsize=(13.4, 9.4),
        caption="换肤不走 TCP。开关同时连 QSettings 与 applyTheme；图表为换色复用已有业绩/桩状态接口。",
    )


def build_sequences(outdir: str) -> None:
    draw_sequence(
        "图 3-1-2a  账号管理与登录",
        ["车主", "LoginDialog", "ServerApiClient", "服务端"],
        [
            (0, 1, "11 位手机号 + 密码"),
            (1, 2, "phoneLogin"),
            (2, 3, "user.phoneLogin"),
            (3, 2, "ok + token + user", "reply"),
            (2, 1, "缓存 token，返回 User", "reply"),
            (1, 0, "进入 MainWindow", "reply"),
        ],
        os.path.join(outdir, "fig_3_1_2a_user_login.png"),
        note="登录失败不自动注册。注册走独立四字段提交，成功后同样进入登录态。",
    )
    draw_sequence(
        "图 3-1-2b  找站与选桩",
        ["车主", "MainWindow", "LocationProvider", "ServerApiClient", "服务端"],
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
        os.path.join(outdir, "fig_3_1_2b_user_find.png"),
        note="距离排序在拿到站点列表后于本端展示；定位失败不阻断找站。",
    )
    draw_sequence(
        "图 3-1-2c  预约与充电",
        ["车主", "MainWindow", "ServerApiClient", "服务端"],
        [
            (0, 1, "对空闲桩预约"),
            (1, 2, "createReservation(pileId)"),
            (2, 3, "reservation.create"),
            (3, 2, "锁桩 15 分钟 + 预约单", "reply"),
            (0, 1, "开始充电"),
            (1, 2, "startCharging"),
            (2, 3, "charge.start"),
            (3, 2, "订单 + 启动进度", "reply"),
            (1, 2, "updateChargingProgress（定时）"),
            (0, 1, "结束充电"),
            (1, 2, "stopCharging"),
            (2, 3, "charge.stop"),
            (3, 2, "结算后的订单", "reply"),
        ],
        os.path.join(outdir, "fig_3_1_2c_user_charge.png"),
        note="同一用户最多 3 条有效预约；同时只允许一笔进行中订单。界面负责倒计时与进度展示。",
    )
    draw_sequence(
        "图 3-1-2d  充值与订单",
        ["车主", "个人中心", "ServerApiClient", "服务端"],
        [
            (0, 1, "输入充值金额"),
            (1, 2, "rechargeUser(amount)"),
            (2, 3, "wallet.recharge"),
            (3, 2, "新余额", "reply"),
            (2, 1, "刷新余额标签", "reply"),
            (0, 1, "打开充电记录"),
            (1, 2, "listOrders"),
            (2, 3, "orders.list"),
            (3, 2, "订单列表", "reply"),
            (1, 0, "表格展示中文状态", "reply"),
        ],
        os.path.join(outdir, "fig_3_1_2d_user_pay.png"),
    )
    draw_sequence(
        "图 3-2-2a  管理员登录 / 邀请码注册",
        ["管理员", "LoginDialog", "AdminApiClient", "服务端"],
        [
            (0, 1, "输入账号密码 或 填写邀请码"),
            (1, 2, "loginAdmin / registerAdmin"),
            (2, 3, "admin.login / admin.register"),
            (3, 2, "ok + token + admin", "reply"),
            (2, 1, "缓存 token，返回 Admin", "reply"),
            (1, 0, "关闭登录窗，打开 MainWindow", "reply"),
        ],
        os.path.join(outdir, "fig_3_2_2a_admin_login.png"),
        note="注册必须消耗未使用邀请码；登录失败不建号。客户端只保存 token 与 Admin。",
    )
    draw_sequence(
        "图 3-2-2b  销售业绩刷新",
        ["管理员", "MainWindow", "AdminApiClient", "服务端"],
        [
            (0, 1, "打开销售业绩 / 刷新 / 切天数"),
            (1, 2, "dashboard(7 或 30)"),
            (2, 3, "admin.dashboard"),
            (3, 2, "stats + dailySales + recentOrders", "reply"),
            (1, 1, "拆 payload：KPI / 折线 / 近单", "self"),
            (1, 0, "更新三项控件", "reply"),
        ],
        os.path.join(outdir, "fig_3_2_2b_admin_finance.png"),
        note="一次请求覆盖三块界面。折线在客户端用 Qt Charts 绘制。",
    )
    draw_sequence(
        "图 3-2-2c  电桩/电站删除（两阶段确认）",
        ["管理员", "MainWindow", "AdminApiClient", "服务端"],
        [
            (0, 1, "选择行并确认删除"),
            (1, 2, "deletePile/Station(id, force=false)"),
            (2, 3, "admin.*.delete  {force:false}"),
            (3, 2, "占用则 code=NEED_FORCE", "reply"),
            (1, 0, "二次确认「强制删除」"),
            (0, 1, "确认强制"),
            (1, 2, "deletePile/Station(id, force=true)"),
            (2, 3, "admin.*.delete  {force:true}"),
            (3, 2, "ok", "reply"),
            (1, 0, "刷新状态/桩/站三页", "reply"),
        ],
        os.path.join(outdir, "fig_3_2_2c_admin_delete.png"),
        note="第一次探测占用，第二次才带 force。避免一次点击误删占用设备。",
    )
    draw_sequence(
        "图 3-2-2d  邀请码发放",
        ["管理员", "权限管理页", "AdminApiClient", "服务端"],
        [
            (0, 1, "选择授予角色 operator/auditor"),
            (1, 2, "createInviteCode(role)"),
            (2, 3, "admin.invites.create"),
            (3, 2, "明文 code", "reply"),
            (1, 0, "对话框展示一次性邀请码", "reply"),
        ],
        os.path.join(outdir, "fig_3_2_2d_admin_invite.png"),
        note="创建入口在权限页，消耗入口在注册页。明文只展示一次。",
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
        ("fig_2_1_system.png", build_system),
        ("fig_3_1_user_client.png", build_user_client_overall),
        ("fig_3_1a_user_account.png", build_user_account),
        ("fig_3_1b_user_service.png", build_user_service),
        ("fig_3_1c_user_pay.png", build_user_pay),
        ("fig_3_2_admin_client.png", build_admin_overall),
        ("fig_3_2_1a_admin_account.png", build_admin_account),
        ("fig_3_2_1b_admin_ops.png", build_admin_ops),
        ("fig_3_2_1c_admin_finance.png", build_admin_finance),
        ("fig_3_2_1d_admin_ui.png", build_admin_ui),
    ]
    print(f"字体：{FONT}")
    print(f"输出：{outdir}")
    for name, fn in jobs:
        path = os.path.join(outdir, name)
        fn(path)
        print(f"  写入 {name}")
    build_sequences(outdir)
    print("  写入时序图")
    print("完成。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
