package config

import (
    "net"
    "os"
    "strconv"
    "encoding/json"

    netaddr "github.com/dspinhirne/netaddr-go"
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
var JudgeURL string
var DockerSubnetPool *netaddr.IPv4Net
var DockerPrefix uint8

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
        var tmp []string
        err = json.Unmarshal([]byte(truststr), &tmp)
        if err != nil {
            panic(err)
        }
        for _, now := range tmp {
            ips, _ := net.LookupIP(now)
            for _, ip := range ips {
                Trust = append(Trust, ip.String())
            }
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
    JudgeURL = os.Getenv("JUDGEURL")
    dockersubnetpoolstr, exists := os.LookupEnv("DOCKERSUBNETPOOL")
    if !exists {
        DockerSubnetPool, _ = netaddr.ParseIPv4Net("172.16.0.0/16")
    } else {
        DockerSubnetPool, err = netaddr.ParseIPv4Net(dockersubnetpoolstr)
        if err != nil {
            DockerSubnetPool, _ = netaddr.ParseIPv4Net("172.16.0.0/16")
        }
    }
    dockerprefixstr, exists := os.LookupEnv("DOCKERPREFIX")
    if !exists {
        DockerPrefix = 24
    } else {
        tmp, err := strconv.ParseUint(dockerprefixstr, 10, 8)
        DockerPrefix = uint8(tmp)
        if err != nil {
            DockerPrefix = 24
        }
    }
}
