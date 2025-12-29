package com.pulpolabs.kotlin_example

import android.util.Log
import android.webkit.JavascriptInterface
import com.pulpolabs.kotlin_example.data.Events
import org.json.JSONObject
import java.util.stream.Collectors

public class SDKInterface {

    @JavascriptInterface
    fun onReady(payload: String) {
        Log.d("PulpoAR SkinAI", "SDK is ready: $payload")
    }

    @JavascriptInterface
    fun onError(payload: String) {
        Log.d("PulpoAR SkinAI", "Error: $payload")
    }

    @JavascriptInterface
    fun onPathChange(payload: String) {
        Log.d("PulpoAR SkinAI", "Path changed: $payload")
    }

    @JavascriptInterface
    fun onOnboardingCarouselChange(payload: String) {
        Log.d("PulpoAR SkinAI", "Onboarding carousel changed: $payload")
    }

    @JavascriptInterface
    fun onQuestionnaireComplete(payload: String) {
        Log.d("PulpoAR SkinAI", "Questionnaire completed: $payload")
    }

    @JavascriptInterface
    fun onPhotoUse(payload: String) {
        Log.d("PulpoAR SkinAI", "Photo used: $payload")
    }

    @JavascriptInterface
    fun onPhotoRetake(payload: String) {
        Log.d("PulpoAR SkinAI", "Photo retake requested: $payload")
    }

    @JavascriptInterface
    fun onSkinScoreCalculate(payload: String) {
        Log.d("PulpoAR SkinAI", "Skin score calculated: $payload")
    }

    @JavascriptInterface
    fun onExperienceChange(payload: String) {
        Log.d("PulpoAR SkinAI", "Experience changed: $payload")
    }

    @JavascriptInterface
    fun onRecommendationsReceive(payload: String) {
        Log.d("PulpoAR SkinAI", "Recommendations received: $payload")
    }

    @JavascriptInterface
    fun onProductTryClick(payload: String) {
        Log.d("PulpoAR SkinAI", "Product try clicked: $payload")
    }

    @JavascriptInterface
    fun onAISimulatorAdjust(payload: String) {
        Log.d("PulpoAR SkinAI", "AI Simulator adjusted: $payload")
    }

    @JavascriptInterface
    fun onAddToCart(payload: String) {
        Log.d("PulpoAR SkinAI", "Add to cart: $payload")
    }

    @JavascriptInterface
    fun onProductVisit(payload: String) {
        Log.d("PulpoAR SkinAI", "Product visited: $payload")
    }

    @JavascriptInterface
    fun onEmailButtonClick(payload: String) {
        Log.d("PulpoAR SkinAI", "Email button clicked: $payload")
    }

    @JavascriptInterface
    fun onEmailSend(payload: String) {
        Log.d("PulpoAR SkinAI", "Email sent: $payload")
    }

    @JavascriptInterface
    fun onCameraPermissionDeny(payload: String) {
        Log.d("PulpoAR SkinAI", "Camera permission denied: $payload")
    }

    @JavascriptInterface
    fun onProblemChipClick(payload: String) {
        Log.d("PulpoAR SkinAI", "Problem chip clicked: $payload")
    }

    fun getInitialSDKScript(events: List<Events>): String {
        var script: String = """
                const script = document.createElement('script');
                script.src = 'https://cdn.jsdelivr.net/npm/@pulpoar/plugin-sdk@latest/dist/index.iife.js';
                script.onload = function() {
                  ${makeSdkEvent(events)}
                }
                document.body.appendChild(script);

        """.trimIndent()
        return script
    }

    fun makeSdkEvent(events: List<Events>): String {
        return events.stream().map { event ->
            """
             pulpoar['${event}']((payload)=>{
                AndroidInterface.${event.toString()}(JSON.stringify(payload));
             });
            """.trimIndent()
        }.collect(Collectors.joining("\n"))
    }
}
