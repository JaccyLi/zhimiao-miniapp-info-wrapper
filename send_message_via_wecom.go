package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

var (
	corpID     = ""
	corpSecret = ""
	agentID    = "1000002"
	tokenURL   = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=" +
		corpID + "&corpsecret=" + corpSecret
	sendClient = &http.Client{Timeout: 10 * time.Second}
	msgTo      = os.Args[1]
	subject    = os.Args[2]
	msgBody    = os.Args[2] + "\n\n" + os.Args[3]
	msgURL     string
)

type returnMessage struct {
	Errcode      int    `json:"errcode"`
	Errmsg       string `json:"errmsg"`
	Access_token string `json:"access_token"`
	Expires_in   int    `json:"expires_in`
}

type Text struct {
	Content string `json:"content"`
}
type postBody struct {
	Touser  string `json:"touser"`
	Msgtype string `json:"msgtype"`
	Agentid string `json:"agentid"`
	Text    `json:"text"`
	Safe    int `json:"safe"`
}

var postData = postBody{
	msgTo,
	"text",
	agentID,
	Text{
		msgBody,
	},
	0,
}

func main() {
	var returnMsg = new(returnMessage)
	var contentType = "application/json; charset=UTF-8"
	fmt.Println("send content: ", os.Args[3])

	// fill returnMsg
	errGet := getJson(tokenURL, returnMsg)
	if errGet != nil {
		fmt.Println(errGet)
		return
	}

	// encoding
	jm, _ := json.Marshal(postData)

	msgURL := "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=" + returnMsg.Access_token
	// send message
	_, err := sendClient.Post(msgURL, contentType, bytes.NewBuffer(jm))
	if err != nil {
		panic(err)
	}

}

// get response body which contains json
func getJson(url string, target interface{}) error {
	r, err := sendClient.Get(url)
	if err != nil {
		return err
	}
	defer r.Body.Close()
	return json.NewDecoder(r.Body).Decode(target)
}
