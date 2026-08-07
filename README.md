# Edge AI 研究笔记

> 读研 · 科研 · 开发记录

个人技术博客，记录**读研日常、科研日常与非涉密项目的开发过程**，主要方向为 **MBSE**（基于模型的系统工程）与 **AI** 结合的探索与实践。课题组研究方向涵盖无人协同、模型轻量化与边缘部署、MBSE 及优化算法，致力于仿真智能计算技术研究。

在线访问：[https://flightleaf.github.io/](https://flightleaf.github.io/) ｜ RSS 订阅：[atom.xml](https://flightleaf.github.io/atom.xml)

## 📂 内容分类

文章统一使用以下三大分类组织：

| 分类 | 内容 | 颜色 |
| ---- | ---- | ---- |
| `读研日常` | 研究生生活、学习记录 | 青蓝 `#1BCDFC` |
| `科研日常` | 论文阅读、实验记录、研究方向思考 | 绿色 `#3DC550` |
| `开发记录` | 非涉密项目的开发过程与技术总结 | 橙红 `#FA6400` |

## ✨ 功能特性

- 📝 **Markdown 写作**：使用 `hexo-renderer-marked` 渲染，支持 highlight.js 代码高亮，文章资源随文章目录存放（`post_asset_folder`）
- 🧮 **数学公式**：MathJax 支持，文章 front-matter 加 `mathjax: true` 即可。公式用 `$...$` / `$$...$$` 书写，由 [scripts/math-protect.js](scripts/math-protect.js) 保护原样输出，`\,`、`_` 等 LaTeX 语法不会被渲染器破坏
- 🔍 **站内全文搜索**：集成 local_search，自动生成 `search.json`
- 📰 **RSS 订阅**：自动生成 `atom.xml`（发布文章后生效）
- 🗺️ **Sitemap**：自动生成 `sitemap.xml`，方便搜索引擎收录
- 🖼️ **图片点击放大**：Fancybox 支持（含 Markdown 正文图片）
- 📋 **代码块一键复制**：CopyCode 插件，带复制成功提示
- ⚡ **页面预加载**：Flying Pages 加速访问
- 📚 **相关文章推荐**：基于 `hexo-related-popular-posts`
- 🗂️ **分类 / 标签 / 归档**：主题自动生成列表页，分类带主题色标识
- 💬 **Giscus 评论**：预留配置，接入 GitHub Discussions（当前未启用）
- 📈 **Open Graph**：分享时展示精美卡片

## 🛠️ 技术栈

| 类别 | 技术 |
| ---- | ---- |
| 框架 | [Hexo](https://hexo.io/) `^8.0.0`（静态博客框架，Node.js） |
| 主题 | [hexo-theme-stellar](https://github.com/xaoxuu/hexo-theme-stellar) `^1.33.1` |
| 渲染器 | hexo-renderer-marked、hexo-renderer-ejs、hexo-renderer-pug、hexo-renderer-stylus |
| 生成器 | hexo-generator-index、hexo-generator-archive、hexo-generator-category、hexo-generator-tag |
| 订阅/SEO | hexo-generator-feed（RSS）、hexo-generator-sitemap（站点地图） |
| 部署 | [hexo-deployer-git](https://github.com/hexojs/hexo-deployer-git) → GitHub Pages |
| 依赖管理 | Yarn（`yarn.lock`） |

## 📂 目录结构

```txt
mbse-ai-blog/
├── source/                  # 站点内容
│   ├── _posts/              # 文章（Markdown）
│   ├── _data/               # 主题数据文件（widgets.yml、icons.yml）
│   ├── about/               # 关于页面
│   └── images/              # 站点图片（头像、favicon 等）
├── scaffolds/               # 新文章模板（含分类模板）
├── themes/                  # 主题目录（git 子模块/独立管理）
├── .github/                 # Dependabot 依赖自动更新
├── _config.yml              # 站点主配置（含 feed/sitemap）
├── _config.stellar.yml      # Stellar 主题配置（覆盖主题内置配置）
└── package.json             # 依赖与脚本
```

## 🚀 快速开始

### 环境要求

- Node.js（Hexo 8 需 Node.js 20+）
- npm 或 Yarn

### 安装与运行

```bash
# 1. 安装依赖
npm install

# 2. 本地预览（默认 http://localhost:4000）
npm run server

# 3. 构建静态文件
npm run build

# 4. 清理缓存
npm run clean

# 5. 部署到 GitHub Pages
npm run deploy
```

### 写作

```bash
# 新建文章（自动套用 scaffolds/post.md 模板，默认分类为「读研日常」）
npx hexo new "文章标题"
```

文章 Front Matter 示例：

```markdown
---
title: 文章标题
date: 2026-08-06 10:00:00
# 分类固定使用：读研日常 / 科研日常 / 开发记录
categories:
  - 开发记录
tags:
  - 模型压缩
  - 边缘部署
# 如需置顶可添加: pin: true
---
```

图片资源：`post_asset_folder` 已开启，将图片放在与文章同名的文件夹中，正文直接引用相对路径即可。

## ⚙️ 配置说明

### 站点配置（`_config.yml`）

- **站点信息**：`title`（Edge AI 研究笔记）、`subtitle`、`description`、`author`
- **国际化**：`language: zh-CN`、`timezone: Asia/Shanghai`
- **URL**：`url` 为 `https://flightleaf.github.io/`，文章链接格式 `:year/:month/:day/:title/`
- **主题**：`theme: stellar`
- **RSS**：`feed` 配置（atom.xml，最多 20 篇，含全文）
- **SEO**：`sitemap` 配置（sitemap.xml）
- **部署**：Git 推送到 `FlightLeaf/FlightLeaf.github.io` 仓库的 `main` 分支

### 主题配置（`_config.stellar.yml`）

优先级高于主题内置配置，主要包含：

- **Logo 区域**：头像、站名、副标题（悬停翻转）
- **主导航菜单**：博客 / 关于（自动高亮当前页面）
- **站点结构**：主页 / 文章页 / 自定义页面的左右边栏布局
- **文章设置**：技术排版（tech）、自动摘要 128 字、三大分类主题色、CC BY-NC-SA 4.0 许可、相关文章推荐
- **评论**：Giscus 已预留，填入 `data-repo-id` 和 `data-category-id` 并将 `service` 改为 `giscus` 即可启用
- **页脚**：社交图标 + 导航链接（含 RSS 订阅入口）
- **外观风格**：跟随系统深浅色、青蓝主题色、平滑滚动
- **自定义图标**：`source/_data/icons.yml` 可扩展主题图标库

## 🔧 常用插件

| 插件 | 用途 |
| ---- | ---- |
| `hexo-deployer-git` | Git 部署到 GitHub Pages |
| `hexo-generator-feed` | RSS 订阅（atom.xml） |
| `hexo-generator-sitemap` | 站点地图（sitemap.xml） |
| `hexo-generator-archive` | 文章归档页面 |
| `hexo-generator-category` | 分类页面 |
| `hexo-generator-tag` | 标签页面 |
| `hexo-related-popular-posts` | 相关文章推荐 |
| `hexo-server` | 本地开发服务器 |

## 📦 依赖维护

已配置 [Dependabot](.github/dependabot.yml)，每日自动检查 npm 依赖更新（最多同时 20 个 PR）。

## 📄 许可协议

本博客所有文章除特别声明外，均采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) 许可协议，转载请注明出处。
