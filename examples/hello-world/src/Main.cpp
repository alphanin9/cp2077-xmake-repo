#include <RED4ext/RED4ext.hpp>

#include <format>

namespace
{
RED4ext::v1::PluginHandle s_handle = nullptr;
const RED4ext::v1::Sdk* s_sdk = nullptr;

// Callable from redscript as:
//   native func HelloWorld_Greet(name: String) -> String;
//
// Native functions always take (context, frame, out, a4). Reading arguments off the
// stack frame and advancing past the ParamEnd opcode is the plugin's job.
void Greet(RED4ext::IScriptable* aContext, RED4ext::CStackFrame* aFrame, RED4ext::CString* aOut, int64_t a4)
{
    RED4EXT_UNUSED_PARAMETER(aContext);
    RED4EXT_UNUSED_PARAMETER(a4);

    RED4ext::CString name;
    RED4ext::GetParameter(aFrame, &name);
    aFrame->code++; // skip ParamEnd

    if (s_sdk)
    {
        s_sdk->logger->InfoF(s_handle, "HelloWorld_Greet called with '%s'", name.c_str());
    }

    if (aOut)
    {
        *aOut = RED4ext::CString(std::format("Hello, {}!", name.c_str()).c_str());
    }
}

void PostRegisterTypes()
{
    auto rtti = RED4ext::CRTTISystem::Get();

    auto func = RED4ext::CGlobalFunction::Create("HelloWorld_Greet", "HelloWorld_Greet", &Greet);
    func->AddParam("String", "name");
    func->SetReturnType("String");

    rtti->RegisterFunction(func);
}
} // namespace

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason,
                                        const RED4ext::v1::Sdk* aSdk)
{
    switch (aReason)
    {
    case RED4ext::v1::EMainReason::Load:
    {
        s_handle = aHandle;
        s_sdk = aSdk;

        // Types must be registered from the RTTI callbacks, not from Main: the RTTI
        // system is not populated yet at load time.
        RED4ext::CRTTISystem::Get()->AddPostRegisterCallback(PostRegisterTypes);

        aSdk->logger->Info(aHandle, "HelloWorld loaded");
        break;
    }
    case RED4ext::v1::EMainReason::Unload:
        break;
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"HelloWorld";
    aInfo->author = L"you";
    aInfo->version = RED4EXT_V1_SEMVER(1, 0, 0);
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_LATEST;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
