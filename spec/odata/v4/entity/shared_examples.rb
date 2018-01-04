shared_examples 'a valid product' do
  it { expect(subject).to be_a(OData::Entity) }

  it { expect(subject.name).to eq('Product') }
  it { expect(subject.type).to eq('ODataDemo.Product') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.service_name).to eq('ODataDemo') }

  # Check property types
  it { expect(subject.get_property('ID')).to be_a(OData::Properties::Integer) }
  it { expect(subject.get_property('Name')).to be_a(OData::Properties::String) }
  it { expect(subject.get_property('Description')).to be_a(OData::Properties::String) }
  it { expect(subject.get_property('ReleaseDate')).to be_a(OData::Properties::DateTimeOffset) }
  it { expect(subject.get_property('DiscontinuedDate')).to be_a(OData::Properties::DateTimeOffset) }
  it { expect(subject.get_property('Rating')).to be_a(OData::Properties::Integer) }
  it { expect(subject.get_property('Price')).to be_a(OData::Properties::Double) }

  # Check property values
  it { expect(subject['ID']).to eq(0) }
  it { expect(subject['Name']).to eq('Bread') }
  it { expect(subject['Description']).to eq('Whole grain bread') }
  it { expect(subject['ReleaseDate']).to eq(DateTime.new(1992,1,1,0,0,0,0)) }
  it { expect(subject['DiscontinuedDate']).to be_nil }
  it { expect(subject['Rating']).to eq(4) }
  it { expect(subject['Price']).to eq(2.5) }

  it { expect {subject['NonExistant']}.to raise_error(ArgumentError) }
  it { expect {subject['NonExistant'] = 5}.to raise_error(ArgumentError) }
end

shared_examples 'a valid supplier' do
  it { expect(subject.name).to eq('Supplier') }
  it { expect(subject.type).to eq('ODataDemo.Supplier') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.service_name).to eq('ODataDemo') }

  # Check property types
  it { expect(subject.get_property('ID')).to be_a(OData::Properties::Integer) }
  it { expect(subject.get_property('Name')).to be_a(OData::Properties::String) }
  it { expect(subject.get_property('Address')).to be_a(OData::ComplexType::Property) }
  it { expect(subject.get_property('Location')).to be_a(OData::Properties::Geography::Point) }

  # Check property values
  it { expect(subject['ID']).to eq(0) }
  it { expect(subject['Name']).to eq('Exotic Liquids') }
  it { expect(subject['Address'][ 'Street']).to eq('NE 228th') }
  it { expect(subject['Address'][   'City']).to eq('Sammamish') }
  it { expect(subject['Address'][  'State']).to eq('WA') }
  it { expect(subject['Address']['ZipCode']).to eq('98074') }
  it { expect(subject['Address']['Country']).to eq('USA') }
  xit { expect(subject['Location']).to eq([47.6316604614258, -122.03547668457]) }
end
