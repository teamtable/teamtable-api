module Response
  def json_response(object, status = :ok, error = nil)
    if error
      render json: { error: error }, status: status
    else
      render json: object, status: status, error: error
    end
  end
end
