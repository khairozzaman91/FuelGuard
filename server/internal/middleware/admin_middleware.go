package middleware

import "github.com/gin-gonic/gin"

func AdminOnly() gin.HandlerFunc {
	return func(c *gin.Context) {

		// get role from context
		roleValue, ok := c.Get("user_role")

		// type assertion
		role, isString := roleValue.(string)

		// validation
		if !ok || !isString || role != "admin" {
			c.JSON(403, gin.H{"error": "Admin only"})
			c.Abort()
			return
		}

		c.Next()
	}
}