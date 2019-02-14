class ResourcesController < ApplicationController
  # GET /library
  def index
    resources = policy_scope(Resource)
    @form = Resources::FilterForm.new(Reform::OpenForm.new)

    filtered_resources, page = if @form.validate(filter_params)
      [Resources::FilterService.new(@form, resources).resources, @form.page]
    else
      [resources, 1]
    end

    @resources = filtered_resources.page(page).per(9)
    @resource_tags = @form.resource_tags
    @skip_container = true
  end

  # GET /library/:id
  def show
    @resource = authorize(Resource.find(params[:id]))

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads(current_user)
    @stream_video = @resource.file_url || @resource.video_embed
  rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError
    alert_message = 'Could not find the requested resource! '

    alert_message += if current_founder.present?
      'You might not be authorized to view this resource.'
    else
      'Please try again after signing in as this could be a private resource.'
    end

    redirect_to resources_path, alert: alert_message
  end

  # GET /library/:id/download
  def download
    resource = authorize(Resource.find(params[:id]))
    resource.increment_downloads(current_user)
    redirect_to(resource.link.presence || resource.file_url)
  end

  private

  def filter_params
    input_filter = params.include?(:resources_filter) ? params.require(:resources_filter).permit({ tags: [] }, :search, :created_after) : {}
    input_filter.merge(page: params[:page])
  end
end
