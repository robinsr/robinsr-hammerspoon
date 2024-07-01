local webview = require 'user.lua.ui.webview.webview'

return {
  new = webview.new_webview,
  page = webview.page,
  file = webview.file,
  showing = webview.showing,
  close = webview.close_all,
}
