#include <RED4ext/RED4ext.hpp>

#include <RED4ext/ArchiveXL.hpp>
#include <RED4ext/TweakXL.hpp>

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason,
                                        const RED4ext::v1::Sdk* aSdk)
{
    switch (aReason)
    {
    case RED4ext::v1::EMainReason::Load:
    {
        // PluginHandle is the plugin's HMODULE, so relative paths resolve against
        // red4ext/plugins/ArchiveTweakRegistration/.
        //
        // Both calls are safe to make this early: if ArchiveXL / TweakXL have not
        // finished initialising, the support headers queue the paths and flush them
        // from an RTTI post-register callback.
        //
        // They return false only when the path does not exist -- a true return does not
        // mean ArchiveXL or TweakXL is actually installed. If it is not, nothing is
        // loaded and the calls are silently inert.
        if (!ArchiveXL::RegisterArchives(aHandle, L"archives"))
        {
            aSdk->logger->Warn(aHandle, "no archives/ directory next to the plugin, skipping");
        }

        if (!TweakXL::RegisterTweaks(aHandle, L"tweaks"))
        {
            aSdk->logger->Warn(aHandle, "no tweaks/ directory next to the plugin, skipping");
        }

        aSdk->logger->Info(aHandle, "ArchiveTweakRegistration loaded");
        break;
    }
    case RED4ext::v1::EMainReason::Unload:
        break;
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"ArchiveTweakRegistration";
    aInfo->author = L"you";
    aInfo->version = RED4EXT_V1_SEMVER(1, 0, 0);
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_LATEST;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
