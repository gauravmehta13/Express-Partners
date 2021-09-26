class AppState {
  int? currentStep;

  AppState({this.currentStep});

  AppState.fromAppState(AppState another) {
    currentStep = another.currentStep;
  }
}
