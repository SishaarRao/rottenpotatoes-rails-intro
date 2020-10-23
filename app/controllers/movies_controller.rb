class MoviesController < ApplicationController
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    if params[:ratings]
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    elsif not params[:ratings] and not params[:commit] and session[:ratings]
      @ratings_to_show = session[:ratings]
    else
      @ratings_to_show = @all_ratings
      session[:ratings] = nil
    end

    if params[:sort]
      @sort_key = params[:sort]
      session[:sort] = @sort_key
    elsif not params[:sort] and session[:sort]
      @sort_key = session[:sort]
      params[:sort] = @sort_key
    else
      @sort_key = nil
      session[:sort] = nil
    end
    
    if @ratings_to_show == []
      @movies = Movie.all 
    else
      @movies = Movie.with_ratings(@ratings_to_show)
    end
    
    if @sort_key
      @movies = @movies.order(@sort_key)
      @title_class = params[:sort] == "title" ? "hilite bg-warning" : "hilite"
      @release_date_class = params[:sort] == "release_date" ? "hilite bg-warning" : "hilite"
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
