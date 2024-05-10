package router
import (
    "github.com/gin-gonic/gin"

    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
)

var router *gin.RouterGroup

func Init(r *gin.RouterGroup) {
    router = r
    router.GET("/status", auth.CheckSignIn, status)
    //user.Init(router.Group("/user"))
}

func status(c *gin.Context) {
    c.String(200, "test2")
}
