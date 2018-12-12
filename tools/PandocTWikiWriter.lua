-- ------------------------------------------------------------------------- --
-- Author:          Joey Dumont         <joey.dumont@gmail.com>              --
-- Date created:    Dec. 7th, 2018                                           --
-- Description:     Custom Lua writer for Pandoc. Outputs TWiki markup.      --
-- License:         CC BY-SA 4.0                                             --
--                  <http://creativecommons.org/licenses/by-sa/4.0>          --
--                                                                           --
-- Taken from data/sample.lua in the pandoc GitHub repo.                     --
-- ------------------------------------------------------------------------- --

local pipe = pandoc.pipe
local stringify = (require "pandoc.utils").stringify

-- The global variable PANDOC_DOCUMENT contains the full AST of
-- the document which is going to be written. It can be used to
-- configure the writer.
local meta = PANDOC_DOCUMENT.meta

-- Chose the image format based on the value of the
-- `image_format` meta value.
local image_format = meta.image_format
  and stringify(meta.image_format)
  or "png"
local image_mime_type = ({
    jpeg = "image/jpeg",
    jpg = "image/jpeg",
    gif = "image/gif",
    png = "image/png",
    svg = "image/svg+xml",
  })[image_format]
  or error("unsupported image format `" .. img_format .. "`")

-- Character escaping (now with utf-8)
local function escape(s, in_attribute)

  -- We escape home common HTML symbols.
  new_string = ""
  new_string = new_string:gsub("[<>&]",
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end)

  -- For TWiki installations that don't support Unicode.
  -- We replace some common Unicode-only symbols by their closest ASCII
  -- counterpart.
  for p, c in utf8.codes(s) do
    if (c == 0x2019 or c == 0x2018) then
      new_string = new_string .. "'"
    elseif (c == 0x201C or c == 0x201D) then
      new_string = new_string .. '"'
    elseif (c == 0x00A0) then
      new_string = new_string .. '&nbsp;'
    else
      new_string = new_string .. utf8.char(c)
    end
  end
  return new_string
end

--- Pads str to length len with char from right
local function lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

-- Replace line breaks with line breaks + 3 spaces.
local function IndentLineBreaks(str)
  str = string.gsub(str, "\n\n","\n")
  str = string.gsub(str, "\n",  "\n    ")
  return str
end

-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
    end
  end
  return table.concat(attr_table)
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add(body)
  if #notes > 0 then
    add('<ol class="footnotes">')
    for _,note in pairs(notes) do
      add(note)
    end
    add('</ol>')
  end
  return table.concat(buffer,'\n') .. '\n'
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return escape(s)
end

function Space()
  return " "
end

function SoftBreak()
  return " "
end

function LineBreak()
  return "<br/>"
end

function Emph(s)
  return "_" .. s .. "_"
end

function Strong(s)
  return "*" .. s .. "*"
end

function Subscript(s)
  return "<sub>" .. s .. "</sub>"
end

function Superscript(s)
  return "<sup>" .. s .. "</sup>"
end

function SmallCaps(s)
  return '<span style="font-variant: small-caps;">' .. s .. '</span>'
end

function Strikeout(s)
  return '<del>' .. s .. '</del>'
end

function Link(s, src, tit, attr)
  return "[[" .. escape(src,true) .. "][" .. s .. "]]"
end

function Image(s, src, tit, attr)
  return "<img src='" .. escape(src,true) .. "' title='" ..
         escape(tit,true) .. "'/>"
end

function Code(s, attr)
  return "<verbatim>" .. escape(s) .. "</verbatim>"
end

function InlineMath(s)
  return "\\(" .. escape(s) .. "\\)"
end

function DisplayMath(s)
  return "\\[" .. escape(s) .. "\\]"
end

function SingleQuoted(s)
  return "&lsquo;" .. s .. "&rsquo;"
end

function DoubleQuoted(s)
  return "&ldquo;" .. s .. "&rdquo;"
end

function Note(s)
  local num = #notes + 1
  -- insert the back reference right before the final closing tag.
  s = string.gsub(s,
          '(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- add a list item with the note to the note table.
  table.insert(notes, '<li id="fn' .. num .. '">' .. s .. '</li>')
  -- return the footnote reference, linked to the note.
  return '<a id="fnref' .. num .. '" href="#fn' .. num ..
            '"><sup>' .. num .. '</sup></a>'
end

function Span(s, attr)
  for x,y in pairs(attr) do
    local first = 1
    local last = 1
    if (x == 'class') then
      -- Extract the relevant Twiki macro.
      first,last = string.find(y, 'twiki%-macro ')
      macro_substring = string.sub(y, last+1,string.len(y))

      if (macro_substring == "USERSIG") then
        return '%' .. escape(macro_substring,true) .. '{' .. s .. '}%'
      else
        return '%' .. escape(macro_substring,true) .. '%'
      end
    end
  end
  return "<span" .. attributes(attr) .. ">" .. s .. "</span>"
end

function RawInline(format, str)
  if format == "html" then
    return str
  else
    return ''
  end
end

function Cite(s, cs)
  local ids = {}
  for _,cit in ipairs(cs) do
    table.insert(ids, cit.citationId)
  end
  return "<span class=\"cite\" data-citation-ids=\"" .. table.concat(ids, ",") ..
    "\">" .. s .. "</span>"
end

function Plain(s)
  return s
end

function Para(s)
  return s
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  return "---" .. string.rep("+",lev) .. " " .. s
end

function BlockQuote(s)
  return "<blockquote>\n" .. s .. "\n</blockquote>"
end

function HorizontalRule()
  return "<hr/>"
end

function LineBlock(ls)
  return '<div style="white-space: pre-line;">' .. table.concat(ls, '\n') ..
         '</div>'
end

function CodeBlock(s, attr)
  return "<verbatim>" .. escape(s) .. "</verbatim>"
end

function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "   * " .. IndentLineBreaks(item))
  end
  return table.concat(buffer, "\n")
end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, "   1. " .. IndentLineBreaks(item))
  end
  return table.concat(buffer, "\n")
end

function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    local k, v = next(item)
    table.insert(buffer, "   $ " .. k .. ": " .. v)
  end
  return table.concat(buffer, "\n")
end

-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
function html_align(align)
  if align == 'AlignLeft' then
    return 'left'
  elseif align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
  end
end

function CaptionedImage(src, tit, caption, attr)
   return '<div class="figure">\n<img src="' .. escape(src,true) ..
      '" title="' .. escape(tit,true) .. '"/>\n' ..
      '<p class="caption">' .. caption .. '</p>\n</div>'
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
-- TODO: Deal with alignment.
function Table(caption, aligns, widths, headers, rows)
  -- Buffer to hold the table, and function to tadd to the buffer.
  local buffer = {}
  local function add(s)
    table.insert(buffer,s)
  end

  -- Determine the longest string in the table, per column.
  local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

  local max_length = {}

  for i,h in pairs(headers) do
    table.insert(max_length,string.len(h))
  end

  for _,row in pairs(rows) do
    for i,c in pairs(row) do
      max_length[i] = string.len(c) > max_length[i] and string.len(c) or max_length[i]
    end
  end

  local header_row = {}
  local empty_header = true
  for i, h in pairs(headers) do
    local align = html_align(aligns[i])
    if (align == 'center') then
      table.insert(header_row, "|  *" .. lpad(h,max_length[i]) .. "*  ")
    elseif (align == 'right') then
      table.insert(header_row, "|   *" .. lpad(h,max_length[i]) .. "* ")
    else
      table.insert(header_row, "| *" .. lpad(h,max_length[i]) .. "*  ")
    end
    empty_header = empty_header and h == ""
  end
  table.insert(header_row, " |\n")

  for _,h in pairs(header_row) do
    add(h)
  end

  for _, row in pairs(rows) do
    for i,c in pairs(row) do
      add("| " .. lpad(c,max_length[i]) .. "    ")
    end
    add(" |\n")
  end

  return table.concat(buffer)

end

function RawBlock(format, str)
  if format == "html" then
    return str
  else
    return ''
  end
end

function Div(s, attr)
  return "<div" .. attributes(attr) .. ">\n" .. s .. "</div>"
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
