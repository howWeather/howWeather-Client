package com.howweather.client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import es.antonborri.home_widget.HomeWidgetProvider as HomeWidgetBase
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import android.net.Uri

class WeatherHomeWidgetProvider : HomeWidgetBase() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

                // --- 1. 날씨 정보 업데이트 ---
                val temp = widgetData.getString("widget_temp", "--")
                val location = widgetData.getString("widget_location", "위치")
                val description = widgetData.getString("widget_description", "날씨")
                // OpenWeatherMap 아이콘 코드를 SharedPreferences에서 가져옵니다.
                val iconCode = widgetData.getString("widget_icon", null)

                views.setTextViewText(R.id.widget_temperature, "${temp}°")
                views.setTextViewText(R.id.widget_location, location)
                views.setTextViewText(R.id.widget_description, description)

                // 아이콘 코드를 기반으로 적절한 아이콘 리소스를 가져와 설정합니다.
                val iconResId = getWeatherIconResource(iconCode)
                views.setImageViewResource(R.id.widget_weather_icon, iconResId)

                // --- 2. 옷 추천 정보 업데이트 ---
                val upperUrl = widgetData.getString("widget_upper_url", null)
                val outerUrl = widgetData.getString("widget_outer_url", null)

                views.setViewVisibility(
                    R.id.widget_clothing_layout,
                    if (!upperUrl.isNullOrEmpty() || !outerUrl.isNullOrEmpty()) View.VISIBLE else View.GONE
                )

                if (!upperUrl.isNullOrEmpty()) {
                    views.setViewVisibility(R.id.widget_upper_column, View.VISIBLE)
                    loadImageIntoWidget(context, appWidgetManager, widgetId, views, R.id.widget_upper_image, upperUrl)
                } else {
                    views.setViewVisibility(R.id.widget_upper_column, View.GONE)
                }

                if (!outerUrl.isNullOrEmpty()) {
                    views.setViewVisibility(R.id.widget_outer_column, View.VISIBLE)
                    loadImageIntoWidget(context, appWidgetManager, widgetId, views, R.id.widget_outer_image, outerUrl)
                } else {
                    views.setViewVisibility(R.id.widget_outer_column, View.GONE)
                }

                val intent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("/")
                )
                views.setOnClickPendingIntent(R.id.widget_root, intent)

                appWidgetManager.updateAppWidget(widgetId, views)

            } catch (e: Exception) {
                Log.e("WeatherWidgetProvider", "onUpdate failed for widgetId $widgetId", e)
            }
        }
    }

    /**
     * OpenWeatherMap 아이콘 코드를 기반으로 적절한 drawable 리소스 ID를 반환합니다.
     * @param iconCode 날씨 아이콘 코드 (예: "01d", "10n")
     * @return 날씨 아이콘의 리소스 ID
     */
    private fun getWeatherIconResource(iconCode: String?): Int {
        return when (iconCode) {
            // 맑음 (Clear Sky)
            "01d" -> R.drawable.ic_clear_sky_day
            "01n" -> R.drawable.ic_clear_sky_night

            // 구름 조금 (Few Clouds)
            "02d" -> R.drawable.ic_few_clouds_day
            "02n" -> R.drawable.ic_few_clouds_night

            // 흩어진 구름 (Scattered Clouds)
            "03d", "03n" -> R.drawable.ic_scattered_clouds

            // 흐림 (Broken Clouds)
            "04d", "04n" -> R.drawable.ic_broken_clouds

            // 소나기 (Shower Rain)
            "09d" -> R.drawable.ic_rain_day // 주간/야간 구분이 필요하면 파일 추가
            "09n" -> R.drawable.ic_rain_night // 주간/야간 구분이 필요하면 파일 추가

            // 비 (Rain)
            "10d", "10n" -> R.drawable.ic_shower_rain

            // 뇌우 (Thunderstorm)
            "11d", "11n" -> R.drawable.ic_thunderstorm

            // 눈 (Snow)
            "13d", "13n" -> R.drawable.ic_snow

            // 안개 (Mist)
            "50d", "50n" -> R.drawable.ic_mist

            // 매칭되는 아이콘이 없을 경우 기본값
            else -> R.drawable.ic_clear_sky_day
        }
    }

    private fun loadImageIntoWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        views: RemoteViews,
        imageViewId: Int,
        imageUrl: String
    ) {
        try {
            Glide.with(context.applicationContext)
                .asBitmap()
                .load(imageUrl)
                .into(object : CustomTarget<Bitmap>() {
                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                        views.setImageViewBitmap(imageViewId, resource)
                        appWidgetManager.updateAppWidget(widgetId, views)
                    }
                    override fun onLoadCleared(placeholder: Drawable?) {
                        // 필요한 경우 플레이스홀더 이미지 처리
                    }
                })
        } catch (e: Exception) {
            Log.e("WeatherWidgetProvider", "Failed to load image: $imageUrl", e)
        }
    }
}