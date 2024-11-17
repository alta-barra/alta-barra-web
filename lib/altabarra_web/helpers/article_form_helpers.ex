defmodule AltabarraWeb.ArticleFormHelpers do
  def form_title(changeset) do
    case Ecto.Changeset.get_field(changeset, :status) do
      :draft -> "Draft Article"
      :in_review -> "Review Article"
      :scheduled -> "Scheduled Article"
      :published -> "Published Article"
      :unpublished -> "Unpublished Article"
      :archived -> "Archived Article"
    end
  end

  def status_options(changeset) do
    current_status = Ecto.Changeset.get_field(changeset, :status)

    Altabarra.Content.Article.valid_transitions(current_status)
    |> Enum.map(fn status ->
      {status_label(status), status}
    end)
  end

  def status_label(status) do
    case status do
      :draft -> "Draft"
      :in_review -> "In Review"
      :scheduled -> "Scheduled"
      :published -> "Published"
      :unpublished -> "Unpublished"
      :archived -> "Archived"
    end
  end

  def submit_button_text(changeset) do
    case Ecto.Changeset.get_field(changeset, :status) do
      :draft -> "Save Draft"
      :in_review -> "Submit for Review"
      :scheduled -> "Schedule"
      :published -> "Update"
      :unpublished -> "Save Changes"
      :archived -> "Archive"
    end
  end

  def show_scheduling?(changeset) do
    status = Ecto.Changeset.get_field(changeset, :status)
    status in [:draft, :in_review, :scheduled]
  end

  def min_schedule_time do
    DateTime.utc_now()
    |> DateTime.add(15, :minute)
    |> DateTime.to_iso8601()
  end

  def estimate_reading_time(changeset) do
    content = Ecto.Changeset.get_field(changeset, :content) || ""
    words = content |> String.split() |> length()
    max(1, ceil(words / 200))
  end

  def show_publishing_warning?(changeset) do
    case Ecto.Changeset.get_field(changeset, :status) do
      :published -> true
      :scheduled -> true
      _ -> false
    end
  end

  def publishing_warning_message(changeset) do
    case Ecto.Changeset.get_field(changeset, :status) do
      :published ->
        "This article is currently published. Any changes will be immediately visible to readers."
      :scheduled ->
        scheduled_for = Ecto.Changeset.get_field(changeset, :scheduled_for)
        "This article is scheduled to be published on #{Calendar.strftime(scheduled_for, "%B %d, %Y at %I:%M %p UTC")}"
      _ ->
        nil
    end
  end
end
