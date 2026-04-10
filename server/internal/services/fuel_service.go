package services

import (
	"time"
)

// CalculateNextRefill calculates next refill date (3 days later) + assigns a proper slot
func CalculateNextRefill() (time.Time, string) {
	now := time.Now()

	// ৩ দিন (৭২ ঘণ্টা) যোগ করা
	nextDate := now.AddDate(0, 0, 3)

	// নির্দিষ্ট ঘণ্টা অনুযায়ী স্লট ভাগ করা
	hour := nextDate.Hour()
	var slot string

	switch {
	case hour >= 8 && hour < 13:
		slot = "10:00 AM - 01:00 PM"
	case hour >= 13 && hour < 18:
		slot = "02:00 PM - 06:00 PM"
	case hour >= 18 && hour < 22:
		slot = "06:00 PM - 10:00 PM"
	default:
		// যদি রাত ১০টার পর বা সকাল ৮টার আগে হয়, তবে পরের দিনের প্রথম স্লট
		slot = "10:00 AM - 01:00 PM"
	}

	return nextDate, slot
}