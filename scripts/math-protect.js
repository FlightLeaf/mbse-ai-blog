/**
 * 数学公式保护扩展
 * 让 $...$ 与 $$...$$ 公式内容原样输出，避免 hexo-renderer-marked
 * 破坏 LaTeX 语法（如 \, 被转义为逗号、_ 触发斜体、\( 被吃掉反斜杠）。
 *
 * 用法：文章 front-matter 加 mathjax: true，公式用 $...$ / $$...$$ 书写。
 */
'use strict';

// HTML 转义，避免公式内的 <、> 等符号被浏览器当作标签破坏页面
function escapeHtml(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

// 块级公式 $$...$$（独立成段，内容可跨行）
const mathBlock = {
  name: 'mathBlock',
  level: 'block',
  start(src) {
    return src.indexOf('$$')
  },
  tokenizer(src) {
    const match = /^\$\$([\s\S]+?)\$\$/.exec(src)
    if (match) {
      return {
        type: 'mathBlock',
        raw: match[0],
        text: match[1].trim()
      }
    }
    return undefined
  },
  renderer(token) {
    return '<div class="math math-block">$$' + escapeHtml(token.text) + '$$</div>'
  }
}

// 行间公式 \[...\]
const mathDisplay = {
  name: 'mathDisplay',
  level: 'block',
  start(src) {
    return src.indexOf('\\[')
  },
  tokenizer(src) {
    const match = /^\\\[([\s\S]+?)\\\]/.exec(src)
    if (match) {
      return {
        type: 'mathDisplay',
        raw: match[0],
        text: match[1].trim()
      }
    }
    return undefined
  },
  renderer(token) {
    return '<div class="math math-block">\\[' + escapeHtml(token.text) + '\\]</div>'
  }
}

// 行内公式 $...$
// 规则：$ 后不能紧跟空白，结束 $ 前不能是空白，中间不能出现
// 换行（避免吞段落）和未配对的 $，降低普通文本中 $ 的误判。
const mathInline = {
  name: 'mathInline',
  level: 'inline',
  start(src) {
    return src.indexOf('$')
  },
  tokenizer(src) {
    const match = /^\$(?!\s)((?:\\.|[^\\\n$])+?)(?<!\s)\$/.exec(src)
    if (match) {
      return {
        type: 'mathInline',
        raw: match[0],
        text: match[1]
      }
    }
    return undefined
  },
  renderer(token) {
    return '<span class="math math-inline">$' + escapeHtml(token.text) + '$</span>'
  }
}

hexo.extend.filter.register('marked:extensions', function(extensions) {
  extensions.push(mathBlock, mathDisplay, mathInline)
})
