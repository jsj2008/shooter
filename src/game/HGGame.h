namespace HGGame
{
    typedef struct t_keystate
    {
        int fire = 0;
    } t_keystate;
    void initialize();
    void render();
    void update(t_keystate* keystate);
    void onMoveLeftPad(int degree, float power);
}
