simulate do
  runs 10_000

  arms do
    variance = (0.8..1.0).step(0.025).to_a
    treatment N(0, variance)
    placebo N(0, variance)
  end

  test do
    hypothesis :superiority
    statistics :difference_of_means
    distribution :normal

    two_sided
    alpha 0.05
  end

  sample_size do
    beta 0.2
    delta 0.5
  end

  internal_pilot do
    adjust :variance
    at 0.5

    unrestricted
    blinded true, false

    control
  end

  collect do
    folder 'D:/data/simulation_results'

    series do
      alpha
    end
  end

end