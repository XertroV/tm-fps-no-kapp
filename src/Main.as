const string PluginName = Meta::ExecutingPlugin().Name;
const string MenuIconColor = "\\$df5";
const string PluginIcon = Icons::Unlock;
const string MenuTitle = MenuIconColor + PluginIcon + "\\$z " + PluginName;

string GetMenuTitle() {
    return MenuIconColor + LockIcon() + "\\$z " + PluginName;
}

string LockIcon() {
    return S_PatchActive ? Icons::Unlock : Icons::Lock;
}

MemPatcher@ PatchNoSleepExLong = MemPatcher(
    // v jne that we patch to jmp
    "33 C9 E8 ?? ?? ?? ?? 8B 95 ?? 02 00 00 48 8D 8D ?? 02 00 00",
    {2}, {"90 90 90 90 90"}
);

void Main() {
    yield(60);
    if (S_PatchActive) {
        PatchNoSleepExLong.Apply();
    }
}

/** Called when the plugin is unloaded and completely removed from memory.
*/
void OnDestroyed() {
    PatchNoSleepExLong.Unapply();
}
void OnDisabled() {
    PatchNoSleepExLong.Unapply();
}

[Setting hidden]
bool S_PatchActive = true;

void OnEnabled() {
    if (S_PatchActive) {
        PatchNoSleepExLong.Apply();
    }
}

[SettingsTab name="FPS No Kapp (Alt Tab Unlock)"]
void R_S_Main() {
    auto newVal = UI::Checkbox("Patch Active", S_PatchActive);
    if (newVal != S_PatchActive) {
        S_PatchActive = newVal;
        PatchNoSleepExLong.IsApplied = newVal;
    }
}

/** Render function called every frame intended only for menu items in `UI`.
*/
void RenderMenu() {
    if (UI::MenuItem(GetMenuTitle(), "", S_PatchActive)) {
        S_PatchActive = !S_PatchActive;
        PatchNoSleepExLong.IsApplied = S_PatchActive;
    }
}
