#pragma once

#include <Interpreters/IInterpreter.h>
#include <Parsers/IAST_fwd.h>


namespace DB
{

class InterpreterShowPrivilegesQuery : public IInterpreter
{
public:
    InterpreterShowPrivilegesQuery(const ASTPtr & query_ptr_, ContextPtr context_);

    BlockIO execute() override;

    bool ignoreQuota() const override { return true; }
    bool ignoreLimits() const override { return true; }

private:
    ASTPtr query_ptr;
    ContextPtr context;
};

}
