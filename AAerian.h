#pragma once

#include "ITransport.h"
#include "CAvion.h"

class AAerian : ITransport
{
protected:

public:
    virtual void afisare();
    virtual void da1() = 0;
    virtual void nu1() = 0;
    virtual void afisare1();
    void da2();
};