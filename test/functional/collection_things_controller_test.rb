require 'test_helper'

class CollectionThingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collection_things)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collection_thing" do
    assert_difference('CollectionThing.count') do
      post :create, :collection_thing => { }
    end

    assert_redirected_to collection_thing_path(assigns(:collection_thing))
  end

  test "should show collection_thing" do
    get :show, :id => collection_things(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collection_things(:one).to_param
    assert_response :success
  end

  test "should update collection_thing" do
    put :update, :id => collection_things(:one).to_param, :collection_thing => { }
    assert_redirected_to collection_thing_path(assigns(:collection_thing))
  end

  test "should destroy collection_thing" do
    assert_difference('CollectionThing.count', -1) do
      delete :destroy, :id => collection_things(:one).to_param
    end

    assert_redirected_to collection_things_path
  end
end
