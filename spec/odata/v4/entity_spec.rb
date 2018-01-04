require 'spec_helper'
require_relative 'entity/shared_examples'

describe OData::Entity, vcr: {cassette_name: 'v4/entity_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::Entity.new(options) }
  let(:options) { {
      type:         'ODataDemo.Product',
      namespace:    'ODataDemo',
      service_name: 'ODataDemo'
  } }

  it { expect(subject).to respond_to(:name, :type, :namespace, :service_name) }

  it { expect(subject.name).to eq('Product') }
  it { expect(subject.type).to eq('ODataDemo.Product') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.service_name).to eq('ODataDemo') }

  describe '#links' do
    let(:subject) { OData::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/files/v4/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }
    let(:links) do
      {
          'Categories'    => {type: :feed, href: 'Products(0)/Categories'},
          'Supplier'      => {type: :entry, href: 'Products(0)/Supplier'},
          'ProductDetail' => {type: :entry, href: 'Products(0)/ProductDetail'}
      }
    end

    it { expect(subject).to respond_to(:links) }
    it { expect(subject.links.size).to eq(3) }
    it { expect(subject.links).to eq(links) }
  end

  describe '#associations' do
    it { expect(subject).to respond_to(:associations) }
    it { expect(subject.associations.size).to eq(3) }
    it { expect {subject.associations['NonExistant']}.to raise_error(ArgumentError) }
  end

  describe '.with_properties' do
    let(:subject) { OData::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5
    } }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo'
    } }

    it_behaves_like 'a valid product'
  end

  describe '.from_xml' do
    let(:subject) { OData::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/files/v4/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }

    it { expect(OData::Entity).to respond_to(:from_xml) }

    it_behaves_like 'a valid product'

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { OData::Entity.from_xml(supplier_xml, options) }
      let(:supplier_xml) {
        document = ::Nokogiri::XML(File.open('spec/fixtures/files/v4/supplier_0.xml'))
        document.remove_namespaces!
        document.xpath('//entry').first
      }

      it_behaves_like 'a valid supplier'
    end
  end

  describe '#to_xml' do
    let(:subject) { OData::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5
    } }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo'
    } }
    let(:product_xml) {
      File.read('spec/fixtures/files/v4/entity_to_xml.xml')
    }

    # TODO: parse the XML and veryify property values instead?
    # TODO: explicitly assert namespace URIs?
    it { expect(subject.to_xml).to eq(product_xml) }
  end

  describe '.from_json' do
    let(:subject) { OData::Entity.from_json(product_json, options) }
    let(:product_json) {
      File.read('spec/fixtures/files/v4/product_0.json')
    }

    it { expect(OData::Entity).to respond_to(:from_json) }
    it_behaves_like 'a valid product'

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { OData::Entity.from_json(supplier_json, options) }
      let(:supplier_json) {
        File.read('spec/fixtures/files/v4/supplier_0.json')
      }

      it_behaves_like 'a valid supplier'
    end
  end

  describe '#to_json' do
    let(:subject) { OData::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5
    } }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo'
    } }

    it { expect(subject.to_json).to eq(properties.to_json) }
  end
end
