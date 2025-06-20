# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable

# NOTES:
# - It's not possible to write a 100% real end-to-end test here,
#   because test env can't use AWS or any other external services.
# - To simulate AWS S3, we use a simple TCPServer server with predefined responses.
# - Technically we can drop this server and just add some test route to the main app,
#   however, there is no easy way to do this. You can only temporarily replace the whole route set with a test one.
#   Mixing real and test routes is quite a challenge with ugly solution.
# - TCPServer is not production-ready. It is not supposed to correctly support HTTP protocol specs, etc.
RSpec.describe UserFilesController do
  let(:password) { '123123' }
  let(:user) { create(:user, email: 'user@email.com', password: password, password_confirmation: password) }

  let(:shrine_storage_name) { :cache }
  let(:storage_path_prefix) { Shrine.storages[shrine_storage_name].prefix.to_s }
  let(:source_file_name) { 'sample.jpg' }
  let(:source_file_path) { Rails.root.join("spec/fixtures/#{source_file_name}").to_s }
  let(:stored_file_relative_path) { "#{storage_path_prefix}/512cc9ea0fa420e8cac234041bba7ea0.jpg" }
  let(:stored_file_full_path) { Rails.root.join('public', stored_file_relative_path) }
  let(:presign_object) do
    {
      'fields'  => {
        'key'                 => stored_file_relative_path,
        'Content-Disposition' => "inline; filename=\"#{source_file_name}\"; filename*=UTF-8''#{source_file_name}",
        'Content-Type'        => 'image/jpeg',
        'policy'              => '...policy...',
        'x-amz-credential'    => 'xxx/yyy/eu-central-1/s3/aws4_request',
        'x-amz-algorithm'     => 'AWS4-HMAC-SHA256',
        'x-amz-date'          => '20250619T111717Z',
        'x-amz-signature'     => 'abc123'
      },
      'headers' => {},
      'method'  => 'post',
      'url'     => "http://localhost:#{@aws_server_socket.addr[1]}/upload"
    }
  end
  let(:presign_response) do
    [
      200,
      { 'Content-Type' => 'application/json' },
      [presign_object.to_json]
    ]
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    @aws_server_socket = TCPServer.new('localhost', 0) # allocate random port
    @aws_server_thread = Thread.new do
      while (session = @aws_server_socket.accept)
        begin
          request = session.gets.to_s
          headers = {}

          # read headers
          while (line = session.gets.to_s.chomp) != ''
            key, value = line.split(':', 2)
            headers[key.strip] = value.strip
          end

          # we got some data
          if (headers['Content-Type'] || '').include?('multipart/form-data')
            boundary = headers['Content-Type'].split('boundary=')[1]

            # read full request
            loop do
              line = session.gets.to_s
              break if line.include?("#{boundary}--")
            end
          end

          if request.include?('/upload')
            session.print "HTTP/1.1 204 No Content\r\n"
            session.print "Etag: abc123\r\n"
            session.print "Location: localhost:12345/123.jpg\r\n"
            session.print "Access-Control-Allow-Origin: *\r\n"
            session.print "Access-Control-Expose-Headers: *\r\n"
            session.print "\r\n"
          else
            session.print "HTTP/1.1 200 OK\r\n"
          end

          session.close
        rescue Errno::EPIPE
          # remote client dropped connection before receiving a full response
        end
      end
    rescue IOError
      # socket closed (normal during shutdown)
    end

    # wait for the server to start
    Timeout.timeout(1) do
      loop do
        TCPSocket.new('localhost', @aws_server_socket.addr[1]).close
        break
      rescue Errno::ECONNREFUSED
        sleep 0.05
      end
    end

    # allow requests to our fake AWS server
    @current_csp = Rails.application.config.content_security_policy
    Rails.application.config.content_security_policy.connect_src(
      *Rails.application.config.content_security_policy.connect_src,
      "http://localhost:#{@aws_server_socket.addr[1]}"
    )
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    # shutdown the server
    @aws_server_socket.close
    @aws_server_thread.kill

    # restore original CSP
    Rails.application.config.instance_variable_set(:@content_security_policy, @current_csp)
  end

  before do
    allow(UserFileUploader).to receive(:presign_response).and_return(presign_response)

    # place the file in the proper place on disk (aka make it look it was uploaded)
    FileUtils.cp(source_file_path, stored_file_full_path)
  end

  after do
    # remove the file
    FileUtils.rm(stored_file_full_path)
  end

  describe 'files' do
    it 'allows user to upload files and dynamically changes file status based on result of processing' do
      sign_in(user, password)
      visit '/files'

      # hacky way to trigger file upload
      attach_file 'files[]', source_file_path, make_visible: true

      within '#user_files' do
        expect(page).to have_content(source_file_name)
      end

      user_file = user.user_files.last
      file_dom_id = css_id(user_file)

      within file_dom_id do
        expect(page).to have_css('i.fa-spinner')
      end

      # trigger delayed jobs (to update the file's processing status)
      Sidekiq::Worker.drain_all

      within file_dom_id do
        expect(page).not_to have_css('i.fa-spinner')
      end
    end

    it 'allows user to preview files' do
      user_file = create(:user_file, user:)
      file_dom_id = css_id(user_file)

      sign_in(user, password)
      visit '/files'

      within file_dom_id do
        find('i.fa-magnifying-glass').click
      end

      within '#modal' do
        expect(page).to have_css("img[src*=\"#{user_file.attachment(:preview).id}\"]")
      end
    end

    it 'allows user to download files' do
      user_file = create(:user_file, user:)
      file_dom_id = css_id(user_file)

      sign_in(user, password)
      visit '/files'

      within file_dom_id do
        find('i.fa-download').click
      end

      sleep 0.3 # wait for download

      downloaded_file = downloads.find { |path| File.basename(path) == source_file_name }
      expect(File.size(downloaded_file)).to eq(491)
    end

    it 'allows user to delete files' do
      user_file = create(:user_file, user:)
      file_dom_id = css_id(user_file)

      sign_in(user, password)
      visit '/files'

      accept_prompt do
        within file_dom_id do
          find('i.fa-trash').click
        end
      end

      expect(page).not_to have_css(file_dom_id)

      within '#user_files' do
        expect(page).not_to have_content(source_file_name)
      end
    end
  end
end

# rubocop:enable RSpec/InstanceVariable
