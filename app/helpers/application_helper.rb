module ApplicationHelper
  def fmt_time(t)
    raise ArgumentError.new("Should be a instance of Time/Date/DateTime. #{t.class} given.") unless t.is_a?(Time) or t.is_a?(Date) or t.is_a?(DateTime)
    t.strftime("%F %R%z")
  end

  def company_level_html(product_progress)
    case product_progress
      when Startup::PRODUCT_PROGRESS_IDEA
        'Idea stage'
      when Startup::PRODUCT_PROGRESS_MOCKUP
        'Mockup stage'
      when Startup::PRODUCT_PROGRESS_PROTOTYPE
        'Prototyping'
      when Startup::PRODUCT_PROGRESS_PRIVATE_BETA
        'In Private Beta'
      when Startup::PRODUCT_PROGRESS_PUBLIC_BETA
        'In Public Beta'
      when Startup::PRODUCT_PROGRESS_LAUNCHED
        'Launched'
      else
        '<em>Not Known</em>'.html_safe
    end
  end

  def product_progress_html(product_progress)
    case product_progress
      when Startup::PRODUCT_PROGRESS_IDEA
        'Just an idea'
      when Startup::PRODUCT_PROGRESS_MOCKUP
        'Mockups'
      when Startup::PRODUCT_PROGRESS_PROTOTYPE
        'Prototyping'
      when Startup::PRODUCT_PROGRESS_PRIVATE_BETA
        'In Private Beta'
      when Startup::PRODUCT_PROGRESS_PUBLIC_BETA
        'In Public Beta'
      when Startup::PRODUCT_PROGRESS_LAUNCHED
        'Launched'
      else
        '<em>Not Known</em>'.html_safe
    end
  end

  def profile_image_url(user, gravatar_size: 100, avatar_version: :full)
    if user.avatar?
      case avatar_version
        when :thumb
          user.avatar.thumb.url
        when :mid
          user.avatar.mid.url
        else
          user.avatar_url
      end
    else
      user.gravatar_url(size: gravatar_size, default: 'identicon')
    end
  end
end
