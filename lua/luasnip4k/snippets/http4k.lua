local LANG = "kotlin"
local imports = require("luasnip4k.imports")(LANG)
local hook = imports.hook
local insert_imports = imports.insert_imports

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local function request_snippet(method)
  return s(
    {
      trig = string.lower(method),
      name = "http4k " .. method .. " Request",
      desc = "http4k template for a " .. method .. " request",
    },
    fmta(string.format([[Request(%s, "/<path>")]], method), { path = i(0, "", hook(function()
      return insert_imports {
          "org.http4k.core.Method." .. method,
          "org.http4k.core.Request",
      }
    end))
    })
  )
end

local function response_snippet(status_code, status_name)
  return s(
    {
      trig = tostring(status_code),
      name = "http4k " .. status_code .. " Response",
      desc = "http4k snippet for a HTTP " .. status_code .. " response",
    },
    fmt("Response(" .. status_name .. "){}", { i(0, "", hook(function()
      return insert_imports {
          "org.http4k.core.Response",
          "org.http4k.core.Status.Companion." .. status_name,
      }
    end))
    })
  )
end

local http4k_snippets = {
  s({ trig = "fil", name = "http4k Filter", desc = "http4k template for a request/response filter" }, fmt(
    [[
      Filter {{ next ->
          {{
              {}
              next(it)
          }}
      }}
    ]],
    { i(0, "", hook(function() return insert_imports { "org.http4k.core.Filter" } end)) }
  )),

  s({ trig = "hh", name = "http4k HttpHandler", desc = "http4k snippet for a request/response handler" }, fmt(
    "{{ req: Request -> Response(OK){} }}",
    {
      i(0, "", hook(function ()
        return insert_imports {
          "org.http4k.core.Request",
          "org.http4k.core.Response",
          "org.http4k.core.Status.Companion.OK",
        }
      end))
    }
  )),

  request_snippet("HEAD"),
  request_snippet("GET"),
  request_snippet("POST"),
  request_snippet("PUT"),
  request_snippet("DELETE"),
  request_snippet("OPTIONS"),
  request_snippet("TRACE"),
  request_snippet("PATCH"),
  request_snippet("PURGE"),

  response_snippet(100, "CONTINUE"),
  response_snippet(101, "SWITCHING_PROTOCOLS"),
  response_snippet(200, "OK"),
  response_snippet(201, "CREATED"),
  response_snippet(202, "ACCEPTED"),
  response_snippet(203, "NON-AUTHORITATIVE_INFORMATION"),
  response_snippet(204, "NO_CONTENT"),
  response_snippet(205, "RESET_CONTENT"),
  response_snippet(206, "PARTIAL_CONTENT"),
  response_snippet(300, "MULTIPLE_CHOICES"),
  response_snippet(301, "MOVED_PERMANENTLY"),
  response_snippet(302, "FOUND"),
  response_snippet(303, "SEE_OTHER"),
  response_snippet(304, "NOT_MODIFIED"),
  response_snippet(305, "USE_PROXY"),
  response_snippet(307, "TEMPORARY_REDIRECT"),
  response_snippet(308, "PERMANENT_REDIRECT"),
  response_snippet(400, "BAD_REQUEST"),
  response_snippet(401, "UNAUTHORIZED"),
  response_snippet(402, "PAYMENT_REQUIRED"),
  response_snippet(403, "FORBIDDEN"),
  response_snippet(404, "NOT_FOUND"),
  response_snippet(405, "METHOD_NOT_ALLOWED"),
  response_snippet(406, "NOT_ACCEPTABLE"),
  response_snippet(407, "PROXY_AUTHENTIFICATION_REQUIRED"),
  response_snippet(408, "REQUEST_TIMEOUT"),
  response_snippet(409, "CONFLICT"),
  response_snippet(410, "GONE"),
  response_snippet(411, "LENGTH_REQUIRED"),
  response_snippet(412, "PRECONDITION_FAILED"),
  response_snippet(413, "REQUEST_ENTITY_TOO_LARGE"),
  response_snippet(414, "REQUEST-URI_TOO_LONG"),
  response_snippet(415, "UNSUPPORTED_MEDIA_TYPE"),
  response_snippet(416, "REQUESTED_RANGE_NOT_SATISFIABLE"),
  response_snippet(417, "EXPECTATION_FAILED"),
  response_snippet(418, "I'M_A_TEAPOT"),
  response_snippet(422, "UNPROCESSABLE_ENTITY"),
  response_snippet(426, "UPGRADE_REQUIRED"),
  response_snippet(429, "TOO_MANY_REQUESTS"),
  response_snippet(451, "UNAVAILABLE_FOR_LEGAL_REASONS"),
  response_snippet(500, "INTERNAL_SERVER_ERROR"),
  response_snippet(501, "NOT_IMPLEMENTED"),
  response_snippet(502, "BAD_GATEWAY"),
  response_snippet(503, "SERVICE_UNAVAILABLE"),
  response_snippet(503, "CONNECTION_REFUSED"),
  response_snippet(504, "GATEWAY_TIMEOUT"),
  response_snippet(504, "CLIENT_TIMEOUT"),
  response_snippet(505, "HTTP_VERSION_NOT_SUPPORTED"),
}

ls.add_snippets(LANG, http4k_snippets)
