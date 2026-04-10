package cmd

import (
	"fuel-guard-backend/internal/config"
	"fuel-guard-backend/internal/handlers"
	"fuel-guard-backend/internal/middleware"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"os"
	"time"
)

func Server() {
	// 1. Initialize Database Connection
	config.Connect()

	// 3. Initialize Gin Router
	router := gin.Default()

	// 4. Configure CORS (এটি আপডেট করা হয়েছে যাতে ফ্লাটার কানেকশনে সমস্যা না হয়)
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // সব সোর্স থেকে রিকোয়েস্ট এলাউ করবে
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// 5. API v1 Route Grouping
	api := router.Group("/api/v1")
	{
		// পাবলিক রুট (লগইন এবং রেজিস্ট্রেশন)
		api.POST("/register", handlers.Register)
		api.POST("/login", handlers.Login)

		// --- Protected Routes (JWT টোকেন লাগবে) ---
		protected := api.Group("/")
		protected.Use(middleware.AuthRequired())
		{
			// প্রোফাইল ম্যানেজমেন্ট
			protected.GET("/profile", handlers.GetProfile)
			protected.POST("/update-pump-profile", handlers.UpdateProfile)
			protected.POST("/check-eligibility", handlers.CheckEligibility)
			protected.POST("/submit-fuel", handlers.SubmitFuel)
			protected.GET("/fuel-history", handlers.GetFuelHistory)

			// --- Admin Only Routes ---
			/* 		admin := protected.Group("/admin")
			{
				admin.GET("/pending", handlers.GetPendingOperators)
				admin.POST("/approve", handlers.ApproveOperator)
				admin.GET("/live-stats", handlers.GetLiveStats)
				admin.GET("/station/:id", handlers.GetStationDetails)
			} */

			admin := protected.Group("/admin")
			admin.Use(middleware.AdminOnly()) // 🔥 ADD THIS
			{
				admin.GET("/pending", handlers.GetPendingOperators)
				admin.POST("/approve", handlers.ApproveOperator)
				admin.GET("/live-stats", handlers.GetLiveStats)
				admin.GET("/station/:id", handlers.GetStationDetails)
			}
		}
	}

	// 6. Set Server Port
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// 7. Start the Server (0.0.0.0 দেওয়া হয়েছে যাতে লোকাল আইপি দিয়ে কানেক্ট করা যায়)
	router.Run("0.0.0.0:" + port)
}
