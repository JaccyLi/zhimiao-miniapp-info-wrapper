#!/usr/bin/env bash

url='https://cloud.cn2030.com/sc/wx/HandlerSubscribe.ashx' 

urlHospitalLocation="${url}?act=CustomerList&city=%5b%22%22%2c%22%e4%b8%8a%e6%b5%b7%e5%b8%82%22%2c%22%22%5d&id=0&cityCode=520000&product=0"
cookie="ASP.NET_SessionId=rnpnx3w0e0p3wmwjntndoh4u"
#city=$(echo '["", "北京市", ""]' | tr -d '\n' |od -An -tx1|tr ' ' %)
city='%5b%22%22%2c%22%e5%8c%97%e4%ba%ac%e5%b8%82%22%2c%22%22%5d'
# query vaccine(id=urlHospitalLocation[*].id)

code=(11 12 13 14 15 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65 71 81 82)

if [[ $1 == "getid" ]]
then
  for i in ${code[@]}
  #for i in 21  22 23
  do
      echo
      echo
      echo "code------>: $i"
      curl -L -H	"Host: cloud.cn2030.com" \
  	         -H "Content-Type: application/json" \
  	         -H "Accept: */*" \
  	         -H "Connection: keep-alive" \
  	         -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D57 MicroMessenger/7.0.3(0x17000321) NetType/WIFI Language/zh_CN" \
  	         -H "Referer: https://servicewechat.com/wx2c7f0f3c30d99445/72/page-frame.html" \
  	         -H "zftsl: " \
  	         -H "Accept-Language: zh-cn" \
  	         -H "Accept-Encoding: gzip,deflate,br" \
               --cookie "${cookie}" \
               "${url}?act=CustomerList&city=${city}&id=0&cityCode=${i}0000&product=0" 2> /dev/null | jq '.list[].id' > ./hospital_id/${i}.log

       sleep 1

      curl -L -H	"Host: cloud.cn2030.com" \
  	         -H "Content-Type: application/json" \
  	         -H "Accept: */*" \
  	         -H "Connection: keep-alive" \
  	         -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D57 MicroMessenger/7.0.3(0x17000321) NetType/WIFI Language/zh_CN" \
  	         -H "Referer: https://servicewechat.com/wx2c7f0f3c30d99445/72/page-frame.html" \
  	         -H "zftsl: " \
  	         -H "Accept-Language: zh-cn" \
  	         -H "Accept-Encoding: gzip,deflate,br" \
               --cookie "${cookie}" \
               "${url}?act=CustomerList&city=${city}&id=0&cityCode=${i}0000&product=0" 2> /dev/null | jq '.list[].cname' > ./hospital_cname/${i}_cname.log
       sleep 1

	          paste ./hospital_id/${i}.log ./hospital_cname/${i}_cname.log > ./hospital_id_cname/${i}_id_cname.log
  done
else
  for i in ${code[@]}
  #for i in $(seq 11 52)
  do
    while read line
    do
	    field=$(echo ${line} | awk '{print NF}')
	    if [[ $field -ne 2 ]]
		then
          echo "INFO: Skip id: $(echo ${line} | awk '{print $1}') 医院: $(echo ${line} | awk '{print $2}')"
		  continue
		fi
	    id=$(echo $line | awk '{print $1}')
        curl -L -H	"Host: cloud.cn2030.com" \
    	         -H "Content-Type: application/json" \
    	         -H "Accept: */*" \
    	         -H "Connection: keep-alive" \
    	         -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 12_1_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16D57 MicroMessenger/7.0.3(0x17000321) NetType/WIFI Language/zh_CN" \
    	         -H "Referer: https://servicewechat.com/wx2c7f0f3c30d99445/72/page-frame.html" \
    	         -H "zftsl: " \
    	         -H "Accept-Language: zh-cn" \
    	         -H "Accept-Encoding: gzip,deflate,br" \
                 --cookie "${cookie}" \
	  		     "${url}?act=CustomerProduct&id=${id}" 2> /dev/null | jq '.list' > /tmp/hpv_log/${id}
				  c=$(cat /tmp/hpv_log/${id} | wc -c)
                  if [[ $c == 0 ]];then
                      continue
                  fi
                  sleep 0.8
				  node ./list_process.js ${id} $(echo $line | awk '{print $2}')
#				  sleep 0.1
	done < ./hospital_id_cname/${i}_id_cname.log
  done
fi
