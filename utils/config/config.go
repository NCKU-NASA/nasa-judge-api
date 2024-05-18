package config

import (
    "os"
    "strconv"
    "encoding/json"
)

var Debug bool
var Trust []string
var Port string
var Secret string
var Sessionname string
var Pubkey string
var AdminUser string
var AdminPasswd string
var RedisURL string
var RedisPasswd string
var WorkerConfigPath string

func init() {
    loadenv()
    var err error
    debugstr, exists := os.LookupEnv("DEBUG")
    if !exists {
        Debug = false
    } else {
        Debug, err = strconv.ParseBool(debugstr)
        if err != nil {
            Debug = false
        }
    }
    truststr := os.Getenv("TRUST")
    if truststr == "" {
        Trust = []string{"127.0.0.1", "::1"}
    } else {
        err = json.Unmarshal([]byte(truststr), &Trust)
        if err != nil {
            panic(err)
        }
    }
    Port = os.Getenv("PORT")
    Secret = os.Getenv("SECRET")
    Sessionname = os.Getenv("SESSIONNAME")
    Pubkey = os.Getenv("PUBKEY")
    AdminUser = os.Getenv("ADMINUSER")
    AdminPasswd = os.Getenv("ADMINPASSWD")
    RedisURL = os.Getenv("REDISURL")
    RedisPasswd = os.Getenv("REDISPASSWD")
    WorkerConfigPath = os.Getenv("WORKERCONFIG")
}
