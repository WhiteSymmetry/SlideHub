require 'rails_helper'
require 'spec_helper'
require 'digest/md5'

describe 'AzureEngine' do
  before do
    AzureEngine.configure do |config|
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.cdn_base_url = ''
      config.queue_name = 'my-queue'
      config.azure_storage_access_key = 'azure_storage_access_key'
      config.azure_storage_account_name = 'azure_storage_account_name'
    end
  end

  describe 'resource_endpoint' do
    it 'return URL that includes image bucket name' do
      expect(AzureEngine.resource_endpoint).to eq('https://azure_storage_account_name.blob.core.windows.net/my-image-bucket')
    end
    it 'return CDN URL' do
      AzureEngine.configure do |config|
        config.cdn_base_url = 'https://sushi.example.com'
      end
      expect(AzureEngine.resource_endpoint).to eq('https://sushi.example.com/my-image-bucket')
    end
  end

  describe 'upload_endpoint' do
    it 'return URL that includes bucket name' do
      expect(AzureEngine.upload_endpoint).to eq('https://azure_storage_account_name.blob.core.windows.net/my-bucket')
    end
  end

  describe 'queue_endpoint' do
    it 'return URL that specifies queue endpoint' do
      expect(AzureEngine.queue_endpoint).to eq('https://azure_storage_account_name.queue.core.windows.net/')
    end
  end

  describe 'Blob Queue' do
    it 'passes all tests' do
      module Azure
        module Queue
          class DummyQueueService
            def create_message(queue_name, message)
              nil
            end
            def list_messages(queue_name, timeout, options = {})
              []
            end
            def create_queue(queue_name)
              nil
            end
            def delete_message(queue_name, message_object_id, message_object_pop_receipt)
              nil
            end
          end
        end
        module Entity
          module Queue
            class DummyMessage
              def id
                1
              end
              def pop_receipt
                ''
              end
            end
          end
        end
      end
      allow_any_instance_of(Azure::ClientServices).to receive(:queues).and_return(Azure::Queue::DummyQueueService.new)
      expect(AzureEngine.send_message('hoge')).to eq(nil)
      expect(AzureEngine.receive_message(10)).to eq([])
      expect(AzureEngine.message_exist?([])).to eq(false)
      expect(AzureEngine.message_exist?([Azure::Entity::Queue::DummyMessage.new])).to eq(true)
      expect(AzureEngine.delete_message(Azure::Entity::Queue::DummyMessage.new)).to eq(nil)
      expect(AzureEngine.batch_delete([Azure::Entity::Queue::DummyMessage.new]).class.name).to eq("Array")
    end
  end
end
