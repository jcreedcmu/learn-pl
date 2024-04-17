--[[
Remove all subtrees whose headlines contain class `noexport`.
License:   MIT
Copyright: © Albert Krewinkel
]]

-- I found this code from:
-- https://superuser.com/questions/1577299/limit-what-sections-get-exported-processed-in-pandoc-markdown
-- https://gist.github.com/tarleb/a0f41adfa7b0e5a9be441e945f843299

-- see also https://pandoc.org/lua-filters.html

-- pandoc.utils.make_sections exists since pandoc 2.8
PANDOC_VERSION:must_be_at_least {2,8}

local utils = require 'pandoc.utils'

-- Returns true iff a div is a section div.
local function is_section_div (div)
  return div.t == 'Div'
    and div.classes[1] == 'section'
    and div.attributes.number
end

-- Returns the header element of a section, or nil if the argument is not a
-- section.
local function section_header (div)
  if not div.t == 'Div' then return nil end
  local header = div.content and div.content[1]
  local is_header = is_section_div(div)
    and header
    and header.t == 'Header'
  return is_header and header or nil
end

--- Remove remaining section divs
local function flatten_sections (div)
  local header = section_header(div)
  if not header then
    return nil
  else
    header.identifier = div.identifier
    div.content[1] = header
    return div.content
  end
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

-- Very hacky, might be brittle, but filters out org sections
-- with names starting with "-"
function drop_noexport_sections (div)
  if div.content[1].content[1].text:startswith("-") then
	  return {}
  end
end

--- Setup the document for further processing by wrapping all
--- sections in Div elements.
function setup_document (doc)
  local sections = utils.make_sections(false, nil, doc.blocks)
  return pandoc.Pandoc(sections, doc.meta)
end

return {
  {Pandoc = setup_document},
  {Div = drop_noexport_sections},
  {Div = flatten_sections}
}
