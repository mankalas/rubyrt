require 'color'

describe Color do
  describe 'arithmetics' do
    it { expect(Color[1, 1, 1] + Color[2, 2, 2]).to eq Color[3, 3, 3] }
    it { expect(Color[1, 1, 1] - Color[2, 2, 2]).to eq Color[-1, -1, -1] }
    it { expect(Color[1, 1, 1] * Color[2, 2, 2]).to eq Color[2, 2, 2] }
    it { expect(Color[1, 1, 1] / Color[2, 2, 2]).to eq Color[0, 0, 0] }
    it { expect(Color[1, 1, 1] / Color[2.0, 2.0, 2.0]).to eq Color[0.5, 0.5, 0.5] }
    it { expect(Color[2, 2, 2]**2).to eq Color[4, 4, 4] }
  end
end
