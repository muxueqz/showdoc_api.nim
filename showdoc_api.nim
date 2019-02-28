#!/usr/bin/nim
#
# 文档说明： https://www.showdoc.cc/page/741656402509783 
# 
import os
import uri
import httpclient
import strutils

var api_key = getEnv("api_key")
var api_token = getEnv("api_token")
var url = getEnv("showdoc_siteurl")
# var url ="https://showdoc.site/server/index.php?s=/api/open/fromComments" #同步到的url。使用www.showdoc.cc的不需要修改，使用开源版的请修改

let client = newHttpClient()
proc post_doc(content: string): auto =
  var body = "from=shell&api_key=$1&api_token=$2&content=$3" % [
    api_key, api_token, content
    ]
  echo body
  client.headers = newHttpHeaders({ "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" })
  var response = client.request(url, httpMethod = HttpPost, body = body)
  echo response.status
  echo response.body

type
    line_status = enum
          doc_ready, doc_running, doc_end, doc_none

var file_name = paramStr(1)
var
  l = doc_none
  fd = open(file_name)
  doc_content = ""

for line in fd.lines:
  if "/**" in line:
    l = doc_ready
  elif l == doc_ready and "* showdoc" in line:
    l = doc_running
  elif l == doc_running and "*/" in line:
    l = doc_end
  case l
    of doc_ready, doc_running:
      doc_content.add line & "\n"
    of doc_end:
      doc_content.add line & "\n"
      post_doc(doc_content)
      doc_content = ""
      l = doc_none
    else:
      l = doc_none
            # result=$(sed -n -e '/\/\*\*/,/\*\//p' $chkfile | grep showdoc) # 正则匹配
                    # if  [[ $txt =~ "@url" ]] && [[ $txt =~ "@title" ]]; then
                        # echo -e "\033[32m $chkfile 扫描到内容 , 正在生成文档 \033[0m "
                        # 通过接口生成文档
