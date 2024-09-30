module IncomeIM


export householdIncome, householdIncomePerCapita


# TODO check if correct
# TODO cache for optimisation?
householdIncome(person) = sum(p -> p.income, person.pos.occupants)
householdIncomePerCapita(person) = householdIncome(person) / length(person.pos.occupants)


end

