#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include <format>

namespace
{
// A native class. RedLib derives the RTTI name from the C++ type name, wires up the
// allocator, and generates the stack-frame marshalling for every method listed below --
// no CGlobalFunction::Create, no manual GetParameter calls.
struct Greeter : Red::IScriptable
{
    Red::CString Greet(const Red::CString& aName)
    {
        Red::Log::Channel("HelloWorldRedLib", "Greet('{}')", aName.c_str());
        return Red::CString(std::format("Hello, {}!", aName.c_str()).c_str());
    }

    uint32_t GetGreetCount() const
    {
        return m_greetCount;
    }

    uint32_t m_greetCount{0};

    RTTI_IMPL_TYPEINFO(Greeter);
    RTTI_IMPL_ALLOCATOR();
};

// A plain free function, exposed as a global.
Red::CString Shout(const Red::CString& aName)
{
    return Red::CString(std::format("HELLO, {}!", aName.c_str()).c_str());
}
} // namespace

RTTI_DEFINE_CLASS(Greeter, {
    RTTI_METHOD(Greet);
    RTTI_METHOD(GetGreetCount);
    RTTI_PROPERTY(m_greetCount);
});

RTTI_DEFINE_GLOBALS({
    RTTI_FUNCTION(Shout, "HelloWorldRedLib_Shout");
});

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason,
                                        const RED4ext::v1::Sdk* aSdk)
{
    switch (aReason)
    {
    case RED4ext::v1::EMainReason::Load:
        // Hands every RTTI_DEFINE_* in this DLL to the RTTI system. Without it none of
        // the definitions above are registered.
        Red::TypeInfoRegistrar::RegisterDiscovered();

        aSdk->logger->Info(aHandle, "HelloWorldRedLib loaded");
        break;

    case RED4ext::v1::EMainReason::Unload:
        break;
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"HelloWorldRedLib";
    aInfo->author = L"you";
    aInfo->version = RED4EXT_V1_SEMVER(1, 0, 0);
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_LATEST;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
