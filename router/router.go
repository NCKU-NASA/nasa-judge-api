package router
import (
    "github.com/gin-gonic/gin"

    "github.com/NCKU-NASA/nasa-judge-api/utils/config"
    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
    "github.com/NCKU-NASA/nasa-judge-api/router/status"
    "github.com/NCKU-NASA/nasa-judge-api/router/labs"
)

var router *gin.RouterGroup

func Init(r *gin.RouterGroup) {
    router = r
    router.GET("/", auth.CheckIsTrust, help)
    router.GET("/pubkey", auth.CheckIsTrust, pubkey)
    status.Init(router.Group("/status"))
    labs.Init(router.Group("/labs"))
    //user.Init(router.Group("/user"))
    //score.Init(router.Group("/score"))
}

func help(c *gin.Context) {
    c.String(200, `
Usage: curl <host>/<api> -H 'Content-Type: application/json'

GET:
    pubkey                      Download ssh public key that is documented in the workerspubkeys in config.yaml.
                                return: text

routes:
    status                      Show api status.
    labs                        Show labs info and labs files.
    user                        Show and set user.
    score                       Show score or judge.
`)
}

func pubkey(c *gin.Context) {
    c.String(200, config.Pubkey)
}


