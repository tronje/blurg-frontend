module Main exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Post exposing (..)


url : String
url =
    "http://localhost:7878"


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { posts : List Post
    , postIds : List Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] [], fetchPosts )



-- UPDATE


type Msg
    = FetchPosts (Result Http.Error (List Int))
    | LoadPost (Result Http.Error Post)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPosts (Ok postIds) ->
            let
                newModel =
                    { model | postIds = postIds }
            in
                ( newModel, Cmd.batch (loadPosts newModel) )

        FetchPosts (Err _) ->
            ( model, Cmd.none )

        LoadPost (Ok post) ->
            ( { model | posts = model.posts ++ [ post ] }, Cmd.none )

        LoadPost (Err _) ->
            ( model, Cmd.none )



-- LOADING


fetchPosts : Cmd Msg
fetchPosts =
    let
        req_url =
            url ++ "/api/posts"

        request =
            Http.get req_url (Decode.list Decode.int)
    in
        Http.send FetchPosts request


loadPost : Int -> Cmd Msg
loadPost id =
    let
        req_url =
            url ++ "/api/post/" ++ (toString id)

        request =
            Http.get req_url decodePost
    in
        Http.send LoadPost request


decodePost : Decode.Decoder Post
decodePost =
    Decode.map4 Post
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "author" Decode.string)
        (Decode.field "content" Decode.string)


loadPosts : Model -> List (Cmd Msg)
loadPosts model =
    List.map loadPost model.postIds



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    renderPosts model



-- RENDERING


renderPosts : Model -> Html Msg
renderPosts model =
    div []
        (List.map renderPost (List.sortBy .id model.posts))


renderPost : Post -> Html Msg
renderPost post =
    div []
        [ h2 [ class "title" ] [ text post.title ]
        , h3 [ class "author" ] [ text post.author ]
        , renderContent post.content
        ]


renderContent : String -> Html Msg
renderContent content =
    p [ class "content" ]
        -- intersperse <br /> between lines to keep linebreaks
        (List.intersperse
            (br [] [])
            -- turn each line of the content into a html `text`
            (List.map text (String.split "\n" content))
        )
