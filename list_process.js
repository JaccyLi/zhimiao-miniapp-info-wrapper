#!/usr/bin/env node

const fs = require('fs');

let vaccinKey = '九价';
var args = process.argv.splice(2);
let listFile=`/tmp/hpv_log/${args[0]}`;


//console.log("@listObj: ", listObj);
//console.log("args----->: ", args);
//console.log("listFile->: ", listFile)

let exec = require('child_process').exec;
let cmdStr = '';

let rawdata = fs.readFileSync(listFile);
console.log("rawdata", rawdata);
let listObj = JSON.parse(rawdata);
console.log("listObj", listObj);

function execCmd(cmd) {
  exec(cmd, function(err,stdout,stderr){
    if(err) {
      console.log('Run send message error: '+stderr);
    } else {
      console.log("stdout: ", stdout)
    }
  })
  
}

listObj.forEach((item, index)=>{
    if (item.date != '') {
        console.log('---------')
        if (!item.text.indexOf(vaccinKey)) {
          let msg = `[${item.text}]-可以预约时间段[${item.date}]-医院[${args[1]}]`.replace(/\s/g, '')
          console.log(msg)
          // do other stuff
            if (item.date != '暂无') {
                cmdStr = `go run send_message_via_wecom.go "suo.li" "疫苗可预约" ${msg}`
                execCmd(cmdStr)
            }
        }
    }
})
