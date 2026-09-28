# 《Dust Front RTS Demo》简体中文汉化补丁

把 [Dust Front RTS Demo](https://store.steampowered.com/app/4776100/Dust_Front_RTS_Demo/) 内 **689 条**文本全部翻译为简体中文。

Demo 有两个本地化表：主表 619 条 + 教学关 70 条。

---

## 使用方法

### 安装

1. 下载本仓库（`Code` → `Download ZIP`，或 `git clone`）并解压。
2. 双击 **`install.bat`**。

脚本会按以下顺序确定游戏目录，**任选其一即可**：

| 方式 | 操作 |
|---|---|
| 拖拽 | 把游戏文件夹（`Dust Front RTS Demo`）直接拖到 `install.bat` 图标上 |
| 命令行 | `install.bat "D:\Games\Dust Front RTS Demo"` |
| 手动输入 | 自动查找失败时会提示，可把文件夹拖进窗口再回车 |

自动查找会先读注册表里 Steam 的 `InstallPath`，再扫描 `C:`~`I:` 盘下的
`SteamLibrary` / `Steam` / `Program Files` / `Games` 等常见位置。

安装时会自动把原文件备份为 `resources.assets.backup`。

### 还原 / 卸载

双击 **`uninstall.bat`**，同样支持上面三种指定目录的方式。它会用备份覆盖回去。

如果备份文件丢失了，用 Steam 自校验即可恢复原文件：

> Steam 库 → `Dust Front RTS Demo` → 右键 **属性** → **已安装文件** → **验证游戏文件的完整性**

---

## 仓库结构

```
Dust-Front-RTS-Demo-zh-CN/
├── install.bat                    安装程序
├── uninstall.bat                  还原程序
├── README.md
├── LICENSE                        MIT
├── 翻译对照表.csv                  689 条 键名/英文/俄文/中文 对照
└── Dust Front RTS_Data/
    └── resources.assets           已打补丁的资源文件
```

---

## 补丁原理

游戏的本地化文本存放在 `Dust Front RTS_Data\resources.assets` 里的两个 Unity `TextAsset` 中：

| path_id | 名称 | 条目数 |
|---|---|---|
| 170 | `Localization_DUST_FRONT - Main` | 619 |
| 169 | `Localization_DUST_FRONT - Tutorial-locals` | 70 |

原始格式是三列 CSV：`Keys,Russian,English`。

游戏通过 IL2CPP 代码（`GameAssembly.dll`）根据系统语言决定读取哪一列，而这个列索引
是写死在二进制里的 —— 无法通过"新增一列中文"来扩展。

因此本补丁的做法是：**保留三列结构，把 Russian 列与 English 列的内容都替换为中文**。
这样无论游戏读取哪一列，取到的都是中文。

翻译时完整保留了原文的换行 `\r\n`、富文本标签 `<size=N>` / `<color=#XXXXXX>`
以及 `{0}` 占位符，结构与原文逐行一致。

---

## 字体说明

游戏使用的是传统 `UnityEngine.Font`（不是 TextMeshPro），字体资源为
`LiberationSans`、`Fyodor-BoldExpanded`、`russo-one_regular` 等，**均不含中文字形**。

### 已确认：全部 8 个字体都是「动态字体」

| 文件 | path_id | 字体名 | 字形表 | TTF 数据 | 判定 |
|---|---|---|---|---|---|
| resources.assets | 182 | LiberationSans | 0 | 350200 | 动态 |
| sharedassets0.assets | 2050 | Fyodor-BoldExpanded | 0 | 48716 | 动态 |
| sharedassets0.assets | 2051 | courbd | 0 | 697096 | 动态 |
| sharedassets0.assets | 2052 | Arame | 0 | 52544 | 动态 |
| sharedassets0.assets | 2053 | Arturito Slab | 0 | 116268 | 动态 |
| sharedassets0.assets | 2054 | loaded | 0 | 17200 | 动态 |
| sharedassets1.assets | 198 | russo-one_regular | 0 | 39300 | 动态 |
| sharedassets1.assets | 199 | gost-2-304-italic | 0 | 77956 | 动态 |

判定依据：`m_CharacterRects` 全为空（没有预烘焙的字形矩形），且 `m_FontData` 是完整的 TTF ——
这正是**动态字体**的特征，字形由 FreeType 在运行时按需光栅化。

这一点很关键，因为 Unity 官方文档明确说明：**动态字体遇到缺失字形时，会依次尝试
`m_FontNames` 里的字体，最后回退到平台内置的字体列表**（文档举的例子正是"用拉丁字体渲染东亚文字"）。
所以在中文 Windows 上，中文应当能正常显示，无需替换字体文件。

### 补丁已顺带加固字体回退

为了让回退行为**确定**（而不是依赖 Unity 那份不透明的硬编码列表），
补丁把中文字体名追加进了 `LiberationSans` 的 `m_FontNames`：

```
['Liberation Sans', 'Microsoft YaHei', 'Microsoft YaHei UI', 'SimHei',
 'SimSun', 'Noto Sans CJK SC', 'Source Han Sans SC', 'DengXian']
```

**这个改动不会影响原有显示效果**：由于 `m_FontData` 内嵌了完整 TTF，
Unity 对已有字形一律使用内嵌字体，只有在字形缺失时才会去查 `m_FontNames`。
拉丁文本仍然渲染为原来的 LiberationSans。

已验证：修改前后 `m_FontData` **350200 字节完全一致**，材质与贴图指针
（`m_DefaultMaterial` → pathID 18、`m_Texture` → pathID 100）均保持不变。

### 万一仍显示方块

若进入游戏后中文仍为空白或方块，说明该 Unity 版本的回退链未生效。
届时需要把字体资源的 `m_FontData` 直接替换为中文字体（如思源黑体 / SimHei）。
这是可行的方案（`m_FontData` 就是原始 TTF 字节，UnityPy 可直接改写），
但会改变拉丁文本的字体观感，因此默认没有做。欢迎开 issue 反馈实际效果。

---

## 翻译说明

- 世界观：被战争与剧变摧残的行星，地表覆盖煤烟与混凝土，埋藏旧文明残骸。
- 玩家阵营：**第四工业帝国**，玩家被称为**将军**。
- 敌对阵营：**叛军**、**变异体**；完整版另有**机械进化**（机器人阵营）。
- 基调：柴油朋克 / 苏式重工业 / 废土写实，UI 文案简洁、军事口吻。

统一术语示例：物资 / 零件 / 电力·电网功率 / 补给·补给上限 / 结构值 / 学说 /
突击群 / 部署区 / 战术暂停 / 全球地图 / 机动建造车。

少数英文原文有误的地方，以俄文原文为准进行了修正，例如：

| 键名 | 英文原文 | 实际含义 | 采用译文 |
|---|---|---|---|
| `demo-*-elevation*` | elevation（假朋友） | 敌人强度倍率 | 当前强化 / 强化 x2 / 强化 x3 |
| `item-explShells` | Enhanced land mine | 俄文 `Усиленный фугас` = 强化高爆弹 | 强化高爆弹 |
| `ability-craneArrow` | Aim the arrow | 俄文 `стрела` 指吊臂 | 调整吊臂 |

---

## 校验结果

- 689 / 689 条全部翻译，无遗漏、无空值。
- 与原文逐行比对：换行数量、富文本标签序列、十六进制颜色值、占位符 —— **0 处不一致**。
- 重新解析生成的 CSV：全部为 3 列，无空单元格。
- 写回后重新读取 `resources.assets` 验证：619 + 70 条全部含中文，0 处空值。
- 键名顺序与数量与原始文件完全一致（缺 0 增 0）。

---

## 免责声明

本补丁为粉丝向非官方汉化，仅供学习交流。
`Dust Front RTS` 的一切权利归原作者 / 发行商所有。
本仓库不包含游戏本体，仅提供一个修改过的资源文件；请勿用于商业用途。

若你是权利方且不希望本仓库存在，请开 issue 联系，我会立即删除。
