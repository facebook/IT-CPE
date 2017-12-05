# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
require './spec/spec_helper'
require_relative '../libraries/cpe_log'

describe CPE::Log do
  before do
    allow(File).to receive(:write)
  end
  context 'When using Log.if' do
    context 'and not passing a method' do
      it 'should return nil' do
        expect(CPE::Log.if('What?')).to eq(nil)
      end
    end
    context 'and passing a nil method' do
      it 'should return nil' do
        expect(CPE::Log.if('What?') { nil }).to eq(nil)
      end
    end
    context 'and passing a false method' do
      it 'should return false' do
        expect(CPE::Log.if('chef; OH NO! Thing Failed') { false }).to eq(false)
      end
    end
    context 'and passing a true method' do
      it 'should log and return true' do
        Chef::Log.should_receive(:info).with('chef; Thing worked!')
        expect(CPE::Log.if('Thing worked!') { true })
      end
    end
  end
  context 'When using Log.unless' do
    context 'and passing a nil method' do
      it 'should log and return true' do
        expect(CPE::Log.unless('What?') { nil }).to eq(nil)
      end
    end
    context 'and passing a false method' do
      it 'should log and return true' do
        Chef::Log.should_receive(:info).with('chef; OH NO! Thing Failed')
        expect(CPE::Log.unless('OH NO! Thing Failed') { false }).to eq(false)
      end
    end
    context 'and passing a true method' do
      it 'should return true' do
        Chef::Log.should_not_receive(:info)
        expect(CPE::Log.unless('Thing worked!') { true })
      end
    end
  end
  context 'When using Log.if_else' do
    context 'and not passing a method' do
      it 'should log and return nil' do
        Chef::Log.should_receive(:info).with('chef; status: fail; Hey!')
        expect(CPE::Log.if_else('What?', 'Hey!')).to eq(nil)
      end
    end
    context 'and passing a nil method' do
      it 'should log and return nil' do
        Chef::Log.should_receive(:info).with('chef; status: fail; Hey!')
        expect(CPE::Log.if_else('What?', 'Hey!') { nil }).to eq(nil)
      end
    end
    context 'and passing a false method' do
      it 'should log and return false' do
        Chef::Log.should_receive(:info).with('chef; status: fail; OH NO!')
        expect(CPE::Log.if_else('Yes', 'OH NO!') { false }).to eq(false)
      end
    end
    context 'and passing a true method' do
      it 'should log and return true' do
        Chef::Log.should_receive(:info).
          with('chef; status: success; Thing worked!')
        expect(CPE::Log.if_else('Thing worked!', 'fail') { true })
      end
    end
  end
  context 'When using Log.log' do
    context 'and passing status as foo' do
      it 'should error out' do
        expect { CPE::Log.log('What?', :status => 'foo') }.to raise_error
      end
    end
    context 'and passing status as success' do
      it 'should not error out' do
        expect { CPE::Log.log('Hey', :status => 'success') }.not_to raise_error
      end
    end
  end
end
