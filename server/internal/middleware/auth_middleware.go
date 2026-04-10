package middleware

import (
	"fuel-guard-backend/internal/services"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")

		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "টোকেন পাওয়া যায়নি"})
			c.Abort()
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")

		phone, role, err := services.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "সেশন শেষ হয়েছে, আবার লগইন করুন"})
			c.Abort()
			return
		}

		c.Set("user_phone", phone)
		c.Set("user_role", role)

		c.Next()
	}
}