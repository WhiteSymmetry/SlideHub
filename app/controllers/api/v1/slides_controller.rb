# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#
module Api
  module V1
    class SlidesController < ApplicationController
      def index
        @slides = Slide.all.published.latest.includes(:user).includes(:category)
        @slides = @slides.where('name like ?', "%#{params["name"]}%") if params['name']
      end

      def show
        @slide = Slide.where(:id => params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end

      def transcript
        @slide = Slide.where(:id => params[:id]).published.includes(:user).includes(:category).first
        unless @slide
          not_found
        end
      end

      private
        def not_found
          render json: { "error" => 'No data found' }, :status => 404
        end
    end
  end
end
