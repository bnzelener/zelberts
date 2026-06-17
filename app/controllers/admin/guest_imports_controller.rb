require "csv"

class Admin::GuestImportsController < Admin::BaseController
  # Only the columns we can't import without are required. group_email, phone,
  # and dietary_notes are optional and may be left blank.
  REQUIRED_HEADERS = %w[group_name first_name last_name].freeze

  def new
    @csv_text = ""
    @errors = []
  end

  def create
    @csv_text = params[:csv_text].to_s
    @errors = []
    groups_created = 0
    guests_created = 0

    if @csv_text.strip.empty?
      @errors << "Please paste CSV content."
      return render :new, status: :unprocessable_entity
    end

    begin
      rows = CSV.parse(@csv_text, headers: true)
    rescue CSV::MalformedCSVError => e
      @errors << "Could not parse CSV: #{e.message}"
      return render :new, status: :unprocessable_entity
    end

    missing = REQUIRED_HEADERS - (rows.headers || []).map { |h| h.to_s.strip }
    if missing.any?
      @errors << "Missing required column(s): #{missing.join(', ')}"
      return render :new, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      group_cache = {}

      rows.each_with_index do |row, idx|
        line = idx + 2 # account for header row (1-indexed for humans)
        group_name = row["group_name"].to_s.strip
        group_email = row["group_email"].to_s.strip

        if group_name.blank?
          @errors << "Row #{line}: group_name is required"
          next
        end

        group = group_cache[group_name] ||= begin
          existing = InviteGroup.find_or_initialize_by(name: group_name)
          existing.email = group_email if existing.email.blank? && group_email.present?
          unless existing.save
            @errors << "Row #{line}: invite group '#{group_name}' - #{existing.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback
          end
          existing
        end

        guest = Guest.new(
          invite_group: group,
          first_name: row["first_name"].to_s.strip,
          last_name: row["last_name"].to_s.strip,
          phone: row["phone"].to_s.strip.presence,
          dietary_notes: row["dietary_notes"].to_s.strip.presence,
          plus_one_allowed: truthy?(row["plus_one_allowed"])
        )

        unless guest.save
          @errors << "Row #{line}: #{guest.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end

        guests_created += 1
      end

      groups_created = group_cache.size

      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end

    if @errors.any?
      render :new, status: :unprocessable_entity
    else
      redirect_to admin_guests_path,
                  notice: "Imported #{guests_created} guest#{'s' unless guests_created == 1} across #{groups_created} invite group#{'s' unless groups_created == 1}."
    end
  end

  private

  # Optional `plus_one_allowed` CSV column — blank/absent means not allowed.
  def truthy?(value)
    %w[true yes 1 y].include?(value.to_s.strip.downcase)
  end
end
