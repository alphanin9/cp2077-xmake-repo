#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include <Shared/Hooks/HookManager.hpp>
#include <Shared/Raw/LocalizationSystem/LocalizationSystem.hpp>
#include <Shared/Util/Core.hpp>

namespace
{
namespace Localization = shared::raw::Localization;

// SharedPunk describes game functions as util::RawFunc<AddressHash, Signature>. The hash
// is looked up in RED4ext's address library at first use rather than being a hardcoded
// offset, so these definitions keep working across game patches.
//
// Localization::LocalizationSystem::FetchOnscreen is one such definition:
//   Red::CString* (*)(LocalizationSystem*, Red::CString&, const Red::StringView&)

// Called after the game resolves any onscreen (localized) string.
void OnFetchOnscreen(Localization::LocalizationSystem* aSystem, Red::CString& aOut, const Red::StringView& aKey)
{
    if (!aKey.IsEmpty() && aOut.Length() > 0)
    {
        Red::Log::Channel("SharedPunkReversing", "onscreen '{}' -> '{}'", aKey.Data(), aOut.c_str());
    }
}

void AttachHooks()
{
    // HookAfter runs the callback once the original has produced its result, so aOut is
    // already filled in. The hook target is the RawFunc above -- no manual address
    // arithmetic, no trampoline bookkeeping.
    shared::hook::HookAfter<Localization::LocalizationSystem::FetchOnscreen>(&OnFetchOnscreen);
}

// A global exposed to redscript that reads a localized string straight through
// SharedPunk's wrapper around the reversed function:
//   native func SharedPunkReversing_Onscreen(key: String) -> String;
Red::CString Onscreen(const Red::CString& aKey)
{
    auto* system = Localization::LocalizationSystem::GetInstance();
    if (!system)
    {
        return Red::CString("");
    }

    return system->GetOnscreen(Red::StringView(aKey.c_str()));
}
} // namespace

RTTI_DEFINE_GLOBALS({
    RTTI_FUNCTION(Onscreen, "SharedPunkReversing_Onscreen");
});

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason,
                                        const RED4ext::v1::Sdk* aSdk)
{
    switch (aReason)
    {
    case RED4ext::v1::EMainReason::Load:
        Red::TypeInfoRegistrar::RegisterDiscovered();
        AttachHooks();

        aSdk->logger->Info(aHandle, "SharedPunkReversing loaded");
        break;

    case RED4ext::v1::EMainReason::Unload:
        break;
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"SharedPunkReversing";
    aInfo->author = L"you";
    aInfo->version = RED4EXT_V1_SEMVER(1, 0, 0);
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_LATEST;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
