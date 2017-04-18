module Collage
  class PhotoService
    attr_accessor :photos, :photos_count

    def initialize
      self.photos_count       = 10
      self.photos             = []
      FlickRaw.api_key        = API_KEY
      FlickRaw.shared_secret  = SECRET
    end

    def search_photos(keywords)
      keywords_dup = keywords.compact.dup
      dictionary = Dictionary.new
      self.photos = []
      while photos.size < photos_count
        keywords_dup << dictionary.random_word if keywords_dup.empty?
        keyword = keywords_dup.shift
        photo   = fetch_photos(keyword)
        photos << photo if photo
      end
      photos
    end

    def fetch_photos(keyword)
      options = {
        text: keyword,
        sort: 'interestingness-desc',
        per_page: 1,
        page: 1,
        content_type: 1,
        media: :photos
      }
      flickr_photo = flickr.photos.search(options)
      return if flickr_photo.to_a.empty?

      photo_info  = flickr.photos.getInfo(photo_id: flickr_photo.first['id'])
      photo = photo_info.to_hash
      photo["url"] = FlickRaw.url_b(photo_info)
      photo
    end

    def download
      Dir.chdir("/tmp/collage") do |dir|
        photos.each do |photo|
          file = open(photo["url"])
          file_name = photo["url"].split("/").last
          File.open(File.join(dir, file_name), 'wb') do |f|
            f.write(file.read)
          end
          photo["local_url"] = "#{dir}/#{file_name}"
        end
      end
    end

    def crop
      photos.each do |photo|
        img = Magick::Image.read(photo["local_url"])[0]
        puts img.inspect
        img.crop!(0, 0, 200, 200)
        img.write photo["local_url"]
        puts "cropping done"
      end
    end

    def collage(collage_name)
      bg = Magick::Image.read('bg.png').first
      count =0
      start_x = 0
      start_y = 0

      photos.each do |photo|
        image = Magick::Image.read(photo["local_url"]).first
        puts "Image - #{image}"
        puts "start_x - #{start_x}"
        puts "start_y - #{start_y}"
        bg.composite!(image, start_x, start_y, Magick::OverCompositeOp)
        count += 1
        start_x += 210
        if count == 5
          start_x = 0
          start_y = 210
        end 
      end

      bg.write('collage_name.jpg')
    end

  end
end