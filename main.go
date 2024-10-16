package main
import (
//    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/gin-contrib/sessions"
    "github.com/gin-contrib/sessions/cookie"
    "github.com/go-errors/errors"
    
    "github.com/NCKU-NASA/nasa-judge-lib/utils/docker"
    "github.com/NCKU-NASA/nasa-judge-lib/utils/host"
    
    "github.com/NCKU-NASA/nasa-judge-api/router"
    "github.com/NCKU-NASA/nasa-judge-api/utils/redis"
    "github.com/NCKU-NASA/nasa-judge-api/utils/config"
    "github.com/NCKU-NASA/nasa-judge-api/utils/errutil"
    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
)

func main() {
    defer redis.Close()
    docker.Init(config.JudgeURL, config.DockerSubnetPool, config.DockerPrefix)
    host.Init(config.JudgeURL)
    if !config.Debug {
        gin.SetMode(gin.ReleaseMode)
    }
    store := cookie.NewStore([]byte(config.Secret))
    backend := gin.Default()
    backend.Use(errorHandler)
    backend.Use(gin.CustomRecovery(panicHandler))
    backend.Use(auth.CheckIsTrust)
    backend.Use(sessions.Sessions(config.Sessionname, store))
    backend.Use(auth.AddMeta)
    router.Init(&backend.RouterGroup)
    backend.Run(":"+string(config.Port))
}

func panicHandler(c *gin.Context, err any) {
    goErr := errors.Wrap(err, 2)
    errmsg := ""
    if config.Debug {
        errmsg = goErr.Error()
    }
    errutil.AbortAndError(c, &errutil.Err{
        Code: 500,
        Msg: "Internal server error",
        Data: errmsg,
    })
}

func errorHandler(c *gin.Context) {
    c.Next()

    for _, e := range c.Errors {
        err := e.Err
        if myErr, ok := err.(*errutil.Err); ok {
            if myErr.Msg != nil {
                c.JSON(myErr.Code, myErr.ToH())
            } else {
                c.Status(myErr.Code)
            }
        } else {
            errmsg := ""
            if config.Debug {
                errmsg = err.Error()
            }
            c.JSON(500, gin.H{
                "code": 500,
                "msg": "Internal server error",
                "data": errmsg,
            })
        }
        return
    }
}
